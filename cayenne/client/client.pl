package CayenneClient;
    use strict;
    use warnings;
    use Moose;
    use IO::Socket;
    #attrs
    has 'host_name' => (is => 'rw', isa => 'Str', required => 1, default => 'localhost');
    has 'port' => (is => 'rw', isa => 'Int', required => 1, default => '7777');
#Connect to server    
    sub connect{
        my $self = shift;
        my $conn = IO::Socket::INET->new(
                        Proto   => 'tcp',       
                        PeerAddr=> $self->host_name,
                        PeerPort=> $self->port,
                        Reuse   => 1,
                        ) or die "$!";
        print "Connected to ", $conn->peerhost, # Info message
              " on port: ", $conn->peerport, "\n";
        $conn->autoflush(1);  # Send immediately
        while (<>) {    # Get input from STDIN
                print $conn "free_to_work";       # Send to Server
                last if m/^end/gi;      # If 'end' then exit loop
                my $line = <$conn>;   # Receive echo from server
                if ($line ne "send_operation") {      # If not the same as input
                        print "Error in sending output\n"; # error
                        exit;           # Terminate
                }
        }
        my $res = <$conn>;            # Receive result from server
        $res =~ m/result=(\d*)/gi;      # Get the numeric result from message
        print "Result: $1\n";           # Print the result
        print "End of client\n";        # End of client
        close $conn;                  # Close socket
        
    }
package main;

my $client  = CayenneClient->new();
$client->connect();