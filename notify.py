#
# A very basic python-based Apple Push Notification server that uses the PyAPNS framework:
#    https://github.com/djacobs/PyAPNs
#
# Bob Dugan 11/23/2015
# bdugan@stonehill.edu
#

import time
import random
import logging
from apns import APNs, Frame, Payload

#
# Listener for feedback from Apple's gateway server
#
def response_listener(error_response):
    print 'client get error-response: {}'.format( str(error_response))

#
# Main Program
#

# Get APNs data structure.  You will need to create your own ...Cert.pem and ...Key.pem files and
# locate them in the same directory as this program.  This is an involved process that will require 
# you to:
#   - create a certificate signing request using OSX's Keychain Access tool
#   - create a new app via the iOS Developer Center
#   - create a development SSL certificate for app via the iOS Developer Center
#   - download the development SSL certificate to your OSX machine
#   - create an SSL certificate .pem file via openssl and the SSL certificate you download on
#     your OSX machine (this is the ...Cert.pem file you need below)
#   - create a private key .pem file via the certificate signing request, and .pem SSL 
#     certificate (this is the ...Key.pem file you need below)
#
# An excellent tutorial can be found here:
#   http://www.raywenderlich.com/32960/apple-push-notification-services-in-ios-6-tutorial-part-1
#
print 'Creating APNS'
apns = APNs(use_sandbox=True, 
            enhanced=True, 
            cert_file='./NewsstandStuff/edu.stonehill.NewsstandCert.pem', 
            key_file ='./NewsstandStuff/edu.stonehill.NewsstandKey.pem')

# Token derived from console output from the iOS app and the following sequence:
#   - UIApplicationDelegate -> application:didFinishLaunchingWithOptions: registers for remote notifications
#   - UIApplicationDelegate -> application:didRegisterForRemoteNotificationsWithDeviceToken: gets called
token_hex = '85488af12fe8c717d4fb5c83a7cd6fd341fde4a1832cdff4073ccde1628023d1' 

# Register a response listener to track notification we are sending
print 'Registering response listener'
apns.gateway_server.register_response_listener(response_listener)

# Create notification.  NOTE: content_available=True is critical if we want iOS app to do processing
# while app is in the background.
payload = Payload(alert='Watson, come here I need you.', sound=None, badge=1, content_available=True)
#payload = Payload(sound=None, content_available=True)

# Create a random number id that we can use to track the notification we are sending
identifier = random.getrandbits(32)

# Send notification.
print 'Sending notification'
apns.gateway_server.send_notification(token_hex, payload, identifier=identifier)

print 'Waiting for program to end (takes about a minute to timeout)'
