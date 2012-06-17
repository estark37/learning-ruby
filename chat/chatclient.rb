#!/usr/bin/env ruby

require 'socket'

class ChatClient

  def initialize(room, nickname, server)
    @room = room.strip
    @nickname = nickname.strip
    @host = server.split(":")[0]
    @port = server.split(":")[1].strip
  end

  def connect
    @socket = TCPSocket.new @host, @port
    @socket.puts("ROOM: #{@room}")
    @socket.puts("NAME: #{@nickname}")
  end

  def chat
    talk_th = Thread.new do
      talk
    end
    listen_th = Thread.new do
      listen
    end
    talk_th.join
  end

  def talk
    msg = ''
    while msg.strip != "exit" do
      msg = $stdin.gets
      @socket.puts(msg)
    end
  end

  def listen
    loop do
      msg = @socket.gets
      puts msg
    end
  end

end

if !ARGV[0]
  puts "What chat server do you want to use? (host:port)"
end
addr = ARGV[0] || $stdin.gets

if !ARGV[1]
  puts "What room do you want to join or create?"
end
room = ARGV[1] || $stdin.gets

if !ARGV[2]
  puts "What nickname do you want to use?"
end
nickname = ARGV[2] || $stdin.gets

client = ChatClient.new(room, nickname, addr)
client.connect
client.chat
