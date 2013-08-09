#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013 
## File : xzb_mq_tool.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-02-14>
## Updated: Time-stamp: <2013-08-09 10:20:33>
##-------------------------------------------------------------------
import pika
import sys
import time
import commands

MQ_SERVER="localhost"
PREFETCH_COUNT=10

def insert_message(queue_name, message):
    print "Insert into queue(" + queue_name + "). msg:" + message
    connection = pika.BlockingConnection(pika.ConnectionParameters(host=MQ_SERVER))
    channel = connection.channel()

    channel.queue_declare(queue=queue_name, durable=True)

    channel.basic_publish(exchange='',
                          routing_key=queue_name,
                          body=message,
                          properties=pika.BasicProperties(
                              delivery_mode = 2, # make message persistent
                          ))
    print " [x] Sent %r" % (message,)
    connection.close()

def get_message(queue_name):
    connection = pika.BlockingConnection(pika.ConnectionParameters(host=MQ_SERVER))
    channel = connection.channel()

    channel.queue_declare(queue=queue_name, durable=True)
    print ' [*] Waiting for messages. To exit press CTRL+C'

    channel.basic_qos(prefetch_count=PREFETCH_COUNT)
    channel.basic_consume(callback, queue=queue_name)

    channel.start_consuming()
    
def callback(ch, method, properties, body):
    print " [x] Received %r" % (body,)
    # time.sleep( body.count('.') )
    print " [x] Done"
    ch.basic_ack(delivery_tag = method.delivery_tag)

# xzb_mq_tool.py insert queue_name sudo xzb_fetch_url.sh -f http://haowenz.com/a/bl/2013/2608.html -d webcrawler_raw_haowenz
# xzb_mq_tool.py get snake_worker-shell#1#d1#haowenz.com
if __name__ == "__main__":
    if sys.argv[1] == "insert":
        queue_name = " ".join(sys.argv[2])
        message = " ".join(sys.argv[3:])
        insert_message(queue_name, message)
    else:
        if sys.argv[1] == "get":
            queue_name = sys.argv[2]
            get_message(queue_name)
        else:
            print "Error unknown command:" + str(sys.argv)

## File : xzb_mq_tool ends
