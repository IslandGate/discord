import 'dart:io';
import 'package:nyxx/nyxx.dart';

void main() async{
  String token = Platform.environment['TOKEN'] ?? '';

  final client = await Nyxx.connectGateway(
    token,
    GatewayIntents.allUnprivileged | GatewayIntents.guilds, // Add GatewayIntents.guilds
  );

  final bot = await client.users.fetchCurrentUser();
  print("✅ Bot is online");

  // Wait for the bot to be ready and connected to guilds
  client.onReady.listen((_) async {
    print("Bot is ready!");

    // --- New Code to send message to 'general' channel ---
    // Iterate through all guilds the bot is in
    for (final guild in client.guilds.values) {
      // Find the 'general' text channel
      TextChannel? generalChannel;
      try {
        generalChannel = guild.channels.values.firstWhere(
          (channel) => channel is TextChannel && channel.name == 'general',
        ) as TextChannel?;
      } catch (e) {
        print("Could not find 'general' channel in guild: ${guild.name}. Error: $e");
      }


      if (generalChannel != null) {
        await generalChannel.sendMessage(MessageBuilder(
          content: 'Hello everyone! I just came online.',
        ));
        print("Sent message to 'general' in guild: ${guild.name}");
      } else {
        print("No 'general' text channel found in guild: ${guild.name}");
      }
    }
    // --- End of New Code ---
  });


  client.onMessageCreate.listen((event) async{
    if(event.mentions.contains(bot)) {
      await event.message.channel.sendMessage(MessageBuilder(
        content: 'Hi ${event.message.author.username}, How may I help you today',
        replyId: event.message.id,
      ));
    }
  });

  // Fake Web Server to Keep Render Alive
  var port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  var server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print("🌍 Fake server running on port $port");
  await for (var request in server) {
    request.response
      ..write("Bot is running!")
      ..close();
  }
}
