using Dapr.Client;

var app = WebApplication.CreateBuilder(args).Build();

using HttpClient client = DaprClient.CreateInvokeHttpClient("backend");

app.MapGet("/tobackend", async () =>
{
	await client.PostAsync("/process", new StringContent("ok"));
	return "Submitted...";
});

app.Run();
return 0;