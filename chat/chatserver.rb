#!/usr/bin/env ruby

require 'socket'
require 'thread'

class ChatRoom
  attr_reader :name

  def initialize(name)
    @members = Hash.new
    @name = name
    @semaphore = Mutex.new
  end

  def add(nickname, client)
    @semaphore.synchronize {
      @members[nickname] = client
    }
    broadcast "#{nickname} joined this room."
  end

  def remove(nickname)
    @semaphore.synchronize {
      @members[nickname] = nil
    }
    broadcast "#{nickname} has left this room."
  end

  def send(nickname, msg)
    excl = Hash.new
    excl[nickname] = true
    broadcast "#{nickname}: #{msg}", excl
  end

  def broadcast(msg, exclude = {})
    @members.each do |nickname, clt|
      if clt and !exclude[nickname]
        clt.puts msg
      end
    end
  end
end

class ChatServer

  @@rooms = Hash.new
  @@rooms_semaphore = Mutex.new

  def initialize(client)
    @client = client
    @nickname = ''
  end

  def join_room
    line = @client.gets
    @room_name = line.split(" ")[1]
    line = @client.gets
    @nickname = line.split(" ")[1]

    @@rooms_semaphore.synchronize {
      if !@@rooms[@room_name]
        @@rooms[@room_name] = ChatRoom.new(@room_name)
      end
    }
    @@rooms[@room_name].add(@nickname, @client)
  end

  def leave_room
    @@rooms[@room_name].remove(@nickname)
  end

  def chat
    msg = ''
    loop do
      msg = @client.gets
      if msg.strip == "exit"
        leave_room
        break
      end
      
      @@rooms[@room_name].send(@nickname, msg)
    end
  end

  def close
    @client.close
  end
end

server = TCPServer.new ARGV[0]

loop do
  Thread.start(server.accept) do |client|
    cs = ChatServer.new client
    cs.join_room
    cs.chat
    cs.close
  end
end
