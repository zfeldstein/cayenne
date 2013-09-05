package CayenneServer;
    use Moose;
    use strict;
    use warnings;
    use IO::Socket;
    #attrs
    has 'host_name' => (is => 'rw', isa => 'Str', required => 1, default => 'localhost');
    has 'port' => (is => 'rw', isa => 'Int', required => 1, default => '7777');
    sub listen{
        my $self = shift;
        my $conn = IO::Socket::INET->new(
                        Proto     => 'tcp',             # protocol
                        LocalAddr=> $self->host_name,
                        LocalPort=> $self->port,
                        Reuse     => 1
                        ) or die "$!";
        $conn->listen();       # listen
        $conn->autoflush(1);   # To send response immediately
        print "Starting Cayenne Daemon...\n";
        my $addr;       # Client handle
        while ($addr = $conn->accept() ) {     
                print   "Connected from: ", $addr->peerhost();
                print   " Port: ", $addr->peerport(), "\n";
                my $result;             
                while (<$addr>) {       # Read all messages from client 
                                        # (Assume all valid numbers)
                        last if m/^end/gi;      # if message is 'end' 
                                                # then exit loop
                        print "Received: $_";   # Print received message
                        print $addr $_;         # Send received message back 
                                                # to verify
                        $result += $_;          # Add value to result
                }
                chomp;                  # Remove the 
                if (m/^end/gi) {        # You need this. Otherwise if 
                                        # the client terminates abruptly
                                        # The server will encounter an 
                                        # error when it sends the result back
                                        # and terminate
                        my $send = "result=$result";    # Format result message
                        print $addr "$send\n";          # send the result message
                        print "Result: $send\n";        # Display sent message
                }
                print "Closed connection\n";    # Inform that connection 
                                                # to client is closed
                close $addr;    # close client
                print "At your service. Waiting...\n";  
        # Wait again for next request
        }
    }
    
package main;

my $agent = CayenneServer->new();
$agent->listen();