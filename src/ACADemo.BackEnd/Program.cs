using Azure.Messaging.ServiceBus;

string? connectionString = Environment.GetEnvironmentVariable("servicebus");
if (string.IsNullOrEmpty(connectionString))
{
	Console.Error.WriteLine("No connection string found in env var 'servicebus'");
	return 1;
}

var app = WebApplication.CreateBuilder(args).Build();

ServiceBusClient sbc = new(connectionString);
ServiceBusSender sender = sbc.CreateSender("service");

app.MapPost("/process", async () =>
{
	await sender.SendMessageAsync(new ServiceBusMessage(Guid.NewGuid().ToString()));
});

app.Run();
return 0;