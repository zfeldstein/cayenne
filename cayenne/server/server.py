import optparse
from twisted.application import internet, service
from twisted.internet.protocol import ServerFactory, Protocol
from twisted.python import log
from twisted.protocols.basic import LineReceiver


class CayenneService(service.Service):

    def __init__(self):
        pass

    def startService(self):
        service.Service.startService(self)
        log.msg('Starting Cayenne Worker')
        
    def buildProtocol(self, addr):
        return CayenneProtocol()
        
        
class CayenneProtocol(LineReceiver):

    def connectionMade(self):
        log.msg("Connection Made")
        self.sendLine("send_operation")
        
    def connectionLost(self,reason):
        log.msg("Connection dropped %s" % (reason))
        
    def lineReceived(self, line):
        log.msg("what up g")
            
        
    def dataReceived(self,data):
        #log.msg("Here is the data")
        
        if data.rstrip() == 'hi':
            log.msg("WHATUP")
        #log.msg(data)


class CayenneWorker(ServerFactory):
    
    protocol = CayenneProtocol
    
    def __init__(self, service):
        self.service = service
        


# configuration parameters
port = 7777
iface = 'localhost'


# this will hold the services that combine to form the poetry server
top_service = service.MultiService()

# the poetry service holds the poem. it will load the poem when it is
# started
cayenne_service = CayenneService()
cayenne_service.setServiceParent(top_service)

# the tcp service connects the factory to a listening socket. it will
# create the listening socket when it is started
factory = CayenneWorker(cayenne_service)
tcp_service = internet.TCPServer(port, factory, interface=iface)
tcp_service.setServiceParent(top_service)

# this variable has to be named 'application'
application = service.Application("server")

# this hooks the collection we made to the application
top_service.setServiceParent(application)

# at this point, the application is ready to go. when started by
# twistd it will start the child services, thus starting up the
# poetry server