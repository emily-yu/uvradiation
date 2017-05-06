import tensorflow as tf
import numpy as np
import input_data
import cv2
from scipy import misc
from matplotlib import pyplot as plt
import sys
from bottle import route, run, template, static_file, get, post, request
import urllib2
from PIL import Image
from glob import glob
import os

def weight_variable(shape):
	initial = tf.truncated_normal(shape, stddev=0.1)
	return tf.Variable(initial)

def bias_variable(shape):
	initial = tf.constant(0.1, shape=shape)
	return tf.Variable(initial)

def conv2d(x, W):
	return tf.nn.conv2d(x, W, strides=[1, 1, 1, 1], padding='SAME')

def max_pool_2x2(x):
	return tf.nn.max_pool(x, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME')

def get_image(image_path):
	return transform(imread(image_path))

def transform(image, npx=512, is_crop=True):
    cropped_image = cv2.resize(image, (64,64))

    return np.array(cropped_image)

def imread(path):
    readimage = cv2.imread(path, 1)
    return readimage

def save(checkpoint_dir, step):
    model_name = "model"
    model_dir = "tr"
    checkpoint_dir = os.path.join(checkpoint_dir, model_dir)

    if not os.path.exists(checkpoint_dir):
        os.makedirs(checkpoint_dir)
    saver = tf.train.Saver()
    saver.save(sess, os.path.join(checkpoint_dir, model_name), global_step=step)

sess = tf.Session()

x = tf.placeholder(tf.float32, shape=[8, 64, 64, 3])
y_ = tf.placeholder(tf.float32, shape=[8, 2])

W_conv1 = weight_variable([5, 5, 3, 64])
b_conv1 = bias_variable([64])


h_conv1 = tf.nn.relu(conv2d(x, W_conv1) + b_conv1)
h_pool1 = max_pool_2x2(h_conv1)


W_conv2 = weight_variable([5, 5, 64, 64])
b_conv2 = bias_variable([64])

h_conv2 = tf.nn.relu(conv2d(h_pool1, W_conv2) + b_conv2)
h_pool2 = max_pool_2x2(h_conv2)
# 16 x 16 x 64

h_pool2_flat = tf.reshape(h_pool2, [-1, 16*16*64])

# 16*16*4

W_fc1 = weight_variable([16*16*64, 1024])
b_fc1 = bias_variable([1024])
h_fc1 = tf.nn.relu(tf.matmul(h_pool2_flat, W_fc1) + b_fc1)
# 1024

keep_prob = tf.placeholder(tf.float32)
h_fc1_drop = tf.nn.dropout(h_fc1, keep_prob)

W_fc2 = weight_variable([1024, 2])
b_fc2 = bias_variable([2])

y_conv = tf.nn.softmax(tf.matmul(h_fc1_drop, W_fc2) + b_fc2)

cross_entropy = -tf.reduce_sum(y_*tf.log(y_conv  + 1e-9))
train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)
correct_prediction = tf.equal(tf.argmax(y_conv,1), tf.argmax(y_,1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, "float"))


sess.run(tf.global_variables_initializer())

si = 2;
sl = ["y","n"]
sn = ["malignant","benign"]
length = 192

batch = np.zeros((si*192,1024))
labels = np.zeros((si*192,si))

dataB = glob(os.path.join("benign", "*.png"))


dataM = glob(os.path.join("malignant", "*.png"))
# baseDog_normalized = base/255.0

batchsize = 8

saver = tf.train.Saver()

if sys.argv[1] == "train":
	for i in range(20000):
		for b in range(length//batchsize):	
			# batch_index_start = (i*batchsize/2) % 192 
			# batch_index_end = ((i+1)*batchsize/2) % 192

			batch_files = dataB[b*batchsize/2:(b+1)*batchsize/2]
			batch = np.array([get_image(batch_file) for batch_file in batch_files])

			batch_files2 = dataM[b*batchsize/2:(b+1)*batchsize/2]
			batch2 = np.array([get_image(batch_file2) for batch_file2 in batch_files2])
			print "line133", batch2.shape

			bigArray = np.concatenate((batch, batch2), axis=0)
			print "line140", bigArray.shape

			labels = np.zeros((batchsize, 2))
			print "line143", labels.shape
			labels[0:4,0] = 1;
			labels[4:8,1] = 1;

			train_step.run(session=sess, feed_dict={x: bigArray, y_: labels, keep_prob: 0.5})
			if i%10 == 0:
				train_accuracy = accuracy.eval(session=sess,feed_dict={x:bigArray, y_: labels, keep_prob: 1.0})
				print "epoch %d, step %d, training accuracy %g"%(i, b, train_accuracy)

			if i%50 == 0:
				saver.save(sess, "/Users/kevin/desktop/uvradiation/training/training.ckpt", global_step=i)

elif sys.argv[1] == "server":
    print "server"
else:
	saver.restore(sess, tf.train.latest_checkpoint("/Users/kevin/desktop/uvradiation/training/training.ckpt-0.meta"))
	batch = np.zeros((1,4096))
	print sys.argv[1]
	batch[0] = get_image(sys.argv[1])

	pr = y_conv.eval(feed_dict={x: batch, y_: labels, keep_prob: 1.0})
	value = sl[np.argmax(pr[0])];
	print sn[np.argmax(pr)];



  # print i

# print("test accuracy %g"%accuracy.eval(feed_dict={
    # x: mnist.test.images, y_: mnist.test.labels, keep_prob: 1.0}))
