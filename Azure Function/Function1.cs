using System;
using System.IO;
using System.Net.Http;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Azure.Storage.Blobs;
using System.Text;
using Newtonsoft.Json;

namespace StockDailySummary
{
    public class _FormValues
    {
        // Valores do formulário inseridos pelo user no frontend.
        public string email { get; set; }
        public string stock { get; set; }
    }

    public static class StockDailySummary
    {
        // Variáveis gerais.
        static string CONTAINER_NAME_OUTPUT = "container-output-api";
        static string CONTAINER_NAME_FORM = "container-formdata";

        static string FILE_NAME_OUTPUT = "apioutput-result.json";
        static string FILE_NAME_FORM = "formdata-result.json";

        static string API_URI = "https://apidojo-yahoo-finance-v1.p.rapidapi.com/market/v2/get-quotes?region=US&symbols=";

        // Variáveis de environment na Azure > Function > Configuration > Application settings.
        static string CONNECTION_STRING = Environment.GetEnvironmentVariable("AzureConnectionString", EnvironmentVariableTarget.Process);
        static string API_KEY = Environment.GetEnvironmentVariable("AzureAPIkey", EnvironmentVariableTarget.Process);

        [FunctionName("StockDailySummary")]
        public static async System.Threading.Tasks.Task RunAsync([TimerTrigger("0 5 21 * * 1-5")]TimerInfo myTimer, ILogger log)
        {
            // Log da execução.
            log.LogInformation($"Function triggered at: {DateTime.Now}");
            log.LogInformation("Update number: 15");

            // Referência do blob client.
            BlobServiceClient BSC = new BlobServiceClient(CONNECTION_STRING);

            // Referência do container.
            var containerClient_Form = BSC.GetBlobContainerClient(CONTAINER_NAME_FORM);

            // Referência do blob.
            BlobClient blobClient_Form = containerClient_Form.GetBlobClient(FILE_NAME_FORM);

            // Ler o conteúdo do ficheiro e passar para uma variável.
            var response = await blobClient_Form.DownloadAsync();
            var result = (dynamic)null;
            using (var streamReader = new StreamReader(response.Value.Content))
            {
                while (!streamReader.EndOfStream)
                {
                    result = await streamReader.ReadLineAsync();
                }
            }

            // Fazer o deserialize dos valores do json.
            _FormValues formValue = JsonConvert.DeserializeObject<_FormValues>(result);

            // Log sobre o stock e e-mail selecionado.
            log.LogInformation("Stock selected: " + formValue.stock);
            log.LogInformation("E-mail selected: " + formValue.email);

            // Juntar o link da api uri com o stock selecionado pelo user no frontend.
            string URI_LINK_CONCANATED = API_URI + formValue.stock;            

            // Ir buscar os dados à API do YahooFinance.
            var APIclient = new HttpClient();
            var APIrequest = new HttpRequestMessage
            {
                Method = HttpMethod.Get,
                RequestUri = new Uri(URI_LINK_CONCANATED),
                Headers =
                {
                    { "x-rapidapi-key", API_KEY },
                    { "x-rapidapi-host", "apidojo-yahoo-finance-v1.p.rapidapi.com" },
                },
            };
            using (var APIresponse = await APIclient.SendAsync(APIrequest))
            {
                // Confirmar se o pedido foi feito com sucesso.
                APIresponse.EnsureSuccessStatusCode();

                // Passar a resposta para a variável, em formato string.
                string fileContent = await APIresponse.Content.ReadAsStringAsync();

                // Referência do container.
                var containerClient_Output = BSC.GetBlobContainerClient(CONTAINER_NAME_OUTPUT);

                // Referência do blob.
                BlobClient blobClient_Output = containerClient_Output.GetBlobClient(FILE_NAME_OUTPUT);

                // Converter para bytes e guardar na memória.
                using (MemoryStream memoryStreamFileContent = new MemoryStream(Encoding.UTF8.GetBytes(fileContent)))
                {
                    // Fazer upload do blob com overwrite.
                    await blobClient_Output.UploadAsync(memoryStreamFileContent, true);

                    // Log de finalização.
                    log.LogInformation($"Function finalized at: {DateTime.Now}");
                }
            }
        }
    }
}