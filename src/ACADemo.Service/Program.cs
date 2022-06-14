using Azure.Messaging.ServiceBus;
using Azure.Core;
using Azure.Identity;

string sbNamespace = ReadEnvVar("sb-namespace");
string queueName = ReadEnvVar("sb-queue");

CancellationTokenSource cts = new();
AppDomain.CurrentDomain.ProcessExit += (o, e) => cts.Cancel();

#if DEBUG
TokenCredential credential = new DefaultAzureCredential();
#else
TokenCredential credential = new ManagedIdentityCredential();
#endif

ServiceBusClient sbc = new(sbNamespace, credential);
ServiceBusReceiver reciever = sbc.CreateReceiver(queueName);

while (!cts.Token.IsCancellationRequested)
{
	ServiceBusReceivedMessage message = await reciever.ReceiveMessageAsync(TimeSpan.MaxValue, cts.Token);

	if (!cts.Token.IsCancellationRequested &&
		message != null)
	{
		Console.WriteLine("Processing message: " + message.Body.ToString());

		await reciever.CompleteMessageAsync(message, cts.Token);
	}
}


string ReadEnvVar(string name)
{
	string? val = Environment.GetEnvironmentVariable(name);
	if (val == null || string.IsNullOrEmpty(val)) throw new Exception($"Env var '{name}' was not set!");
	return val;
}