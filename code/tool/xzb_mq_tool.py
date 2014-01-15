#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : xzb_mq_tool.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-02-14>
## Updated: Time-stamp: <2014-01-15 12:33:50>
##-------------------------------------------------------------------
import pika
import sys
import time
import commands
import os
import getopt

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
    
def get_queue_name(message):
    list1 = message.split(" ")
    for item in list1:
        if item.find("http") == 0:
            list2 = item.split("/")
            return "snake_worker-shell#1#d1#" + list2[2]
    print "Error: fail to get_queue_name from message:" + message
    sys.exit(-1)
    return ""

def get_one_message(queue_name):
    connection = pika.BlockingConnection(pika.ConnectionParameters(host=MQ_SERVER))
    channel = connection.channel()

    channel.queue_declare(queue=queue_name, durable=True)
    print ' [*] Waiting for messages. To exit press CTRL+C'

    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(callback_one, queue=queue_name)

    channel.start_consuming()

def callback(ch, method, properties, body):
    print " [x] Received %r" % (body,)
    # time.sleep( body.count('.') )
    print " [x] Done"
    ch.basic_ack(delivery_tag = method.delivery_tag)

def callback_one(ch, method, properties, body):
    print " [x] Received %r" % (body,)
    # time.sleep( body.count('.') )
    print " [x] Done"
    ch.basic_ack(delivery_tag = method.delivery_tag)
    sys.exit(0)

def usage():
    _usage = """Usage: %s <ACTION> <DATA>
# %s insert queue_name sudo xzb_fetch_url.sh -f http://haowenz.com/a/bl/2013/2608.html -d webcrawler_raw_haowenz
# %s get snake_worker-shell#1#d1#haowenz.com
# %s getone snake_worker-shell#1#d1#haowenz.com
"""
    _name_filler = (os.path.basename(sys.argv[0]),) * 3

    print _usage %_name_filler

if __name__ == "__main__":
    # Get options
    try:
        opts, args = getopt.getopt(sys.argv[1:], "h", ["help"])
    except getopt.GetoptError, err:
        print str(err)
        usage()
        sys.exit(1)

    if len(sys.argv) == 1:
        usage()
        sys.exit(1)

    if sys.argv[1] == "insert":
        message = " ".join(sys.argv[2:])
        queue_name = get_queue_name(message)
        insert_message(queue_name, message)
    else:
        if sys.argv[1] == "get":
            queue_name = sys.argv[2]
            get_message(queue_name)
        else:
            if sys.argv[1] == "getone":
                queue_name = sys.argv[2]
                get_one_message(queue_name)
            else:
                print "Error unknown command:" + str(sys.argv)

## File : xzb_mq_tool.py ends
