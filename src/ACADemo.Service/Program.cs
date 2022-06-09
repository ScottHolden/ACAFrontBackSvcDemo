using Azure.Messaging.ServiceBus;

string? connectionString = Environment.GetEnvironmentVariable("servicebus");
if (string.IsNullOrEmpty(connectionString))
{
	Console.Error.WriteLine("No connection string found in env var 'servicebus'");
	return 1;
}

CancellationTokenSource cts = new();
AppDomain.CurrentDomain.ProcessExit += (o, e) => cts.Cancel();

ServiceBusClient sbc = new(connectionString);

ServiceBusReceiver reciever = sbc.CreateReceiver("service");

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

return 0;