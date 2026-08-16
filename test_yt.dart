import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';

void main() async {
  var yt = YoutubeExplode();
  try {
    var videoId = VideoId('tgneSmdEM2c');
    var manifest = await yt.videos.streamsClient.getManifest(videoId);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    print('Stream URL: ${streamInfo.url}');

    // Test with HttpClient
    var client = HttpClient();
    var ytRequest = await client.getUrl(streamInfo.url);
    // DO NOT set User-Agent to see if it works
    var ytResponse = await ytRequest.close();
    print('HttpClient Status (no UA): ${ytResponse.statusCode}');
    await ytResponse.drain();
    print('HttpClient Status: ${ytResponse.statusCode}');
    await ytResponse.drain();

    // Test with yt.videos.streamsClient.get
    print('Testing yt.get...');
    var stream = yt.videos.streamsClient.get(streamInfo);
    var firstChunk = await stream.first;
    print('yt.get success, chunk size: ${firstChunk.length}');
  } catch (e) {
    print('Error: $e');
  } finally {
    yt.close();
  }
}
