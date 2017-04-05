What is this?
=============

This is an example application to work out how to use Email::MIME::Kit
with Catalyst to allow the sending of emails where Template Toolkit
generates the content.

How to use it
=============

Install the dependencies listed in the Makefile.PL

Run script/sendme_server.pl to test the application.

Visit http://localhost:3000/ (remember to adjust the URL if you change
the port number or run it on a machine other than your local machine).

NOTE: By default it sends email from simon@example.com so you may
need to change this if you have some decent spam filtering on your
mailbox!
