package CayenneServer;
    use Moose;
    use strict;
    use warnings;
    use IO::Socket;
    
    #attrs
    has 'host_name' => (is => 'rw', isa => 'Str', required => 1, default => 'localhost');
    has 'port' => (is => 'rw', isa => 'Int', required => 1, default => '7777');
#=======================================
# Process con and send respones
#=======================================    
    
    sub initial_request {
        my $self = shift;
        my $request = shift;
        return "send_operation\n";
    }    

    sub process_conn {
        my $self = shift;
        chomp(my $request = shift);
        print "ayo\n";
        print $request;
        my %actions = ("free_to_work" => \&initial_request);
        if ($actions{$request}) {
            print "Action found";
            &{$actions{$request}};
        }else {
            return "try_again";
        }
        
    }

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
            my $pid = fork();
            die "Can't fork process: $!" unless defined ($pid);
            next if ($pid > 0);
            print   "Connected from: ", $addr->peerhost();
            print   " Port: ", $addr->peerport(), "\n";
            my $result;             
            while (<$addr>) {
                    my $response;
                    last if m/^done/gi;     # if message is 'end' 
                                            # then exit loop
                    print "message from", $addr->peerhost(), ": $_"; # Print received message
                    $response = $self->process_conn($_);
                    print $addr $response."\n";         # Send received message back 

            }
            chomp;                  # Remove the 
            if (m/^done/gi) {        # You need this. Otherwise if 
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
        }
    }
    
package main;

my $agent = CayenneServer->new();
$agent->listen();