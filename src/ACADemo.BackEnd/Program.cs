using Azure.Messaging.ServiceBus;
using Azure.Core;
using Azure.Identity;

string sbNamespace = ReadEnvVar("sb-namespace");
string queueName = ReadEnvVar("sb-queue");

var app = WebApplication.CreateBuilder(args).Build();

#if DEBUG
TokenCredential credential = new DefaultAzureCredential();
#else
TokenCredential credential = new ManagedIdentityCredential();
#endif

ServiceBusClient sbc = new(sbNamespace, credential);
ServiceBusSender sender = sbc.CreateSender(queueName);

app.MapPost("/process", async () =>
{
	await sender.SendMessageAsync(new ServiceBusMessage(Guid.NewGuid().ToString()));
});

app.Run();

string ReadEnvVar(string name)
{
	string? val = Environment.GetEnvironmentVariable(name);
	if (val == null || string.IsNullOrEmpty(val)) throw new Exception($"Env var '{name}' was not set!");
	return val;
}