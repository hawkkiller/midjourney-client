import 'dart:async';

import 'package:midjourney_client/src/core/discord/discord_interaction_client.dart';
import 'package:midjourney_client/src/core/discord/discord_connection.dart';
import 'package:midjourney_client/src/core/midjourney/model/midjourney_message.dart';

abstract interface class MidjourneyApi {
  const MidjourneyApi();

  /// Imagine a new picture with the given [prompt].
  ///
  /// Returns streamed messages of progress.
  Stream<ImageMessage> imagine(String prompt);

  /// Create a new variation based on the picture
  /// 
  /// Returns streamed messages of progress.
  Stream<ImageMessage> variation(ImageMessage$Finish imageMessage, int index); 
}

final class MidjourneyApiDiscordImpl extends MidjourneyApi {
  MidjourneyApiDiscordImpl({
    required this.interactionClient,
    required this.connection,
  });

  final DiscordInteractionClient interactionClient;
  final DiscordConnection connection;

  @override
  Stream<ImageMessage> imagine(String prompt) async* {
    // Add a seed to the prompt to avoid collisions because prompt
    // is the only thing that is lasted between requests.
    prompt = '$prompt --seed ${DateTime.now().microsecondsSinceEpoch % 1000000}';
    final nonce = interactionClient.imagine(prompt);
    yield* connection.waitImageMessage(nonce);
  }

  @override
  Stream<ImageMessage> variation(ImageMessage$Finish imageMessage, int index) async* {
    if (index < 0 && index > 4) {
      throw ArgumentError.value(index, 'index', 'Index must be between 0 and 5');
    }
    final nonce = interactionClient.variation(imageMessage, index);
    yield* connection.waitImageMessage(nonce);
  }
}