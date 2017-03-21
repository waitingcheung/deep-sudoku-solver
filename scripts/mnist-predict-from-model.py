
# coding: utf-8

# In[1]:

import numpy as np
import tensorflow as tf
import os


# In[2]:

def weight_variable(shape, data=None):
    initial = data.reshape(shape) if data is not None else tf.truncated_normal(shape, stddev=0.1)
    return tf.Variable(initial)

def bias_variable(shape, data=None):
    initial = data.reshape(shape) if data is not None else tf.constant(0.1, shape=shape)
    return tf.Variable(initial)
    
def conv2d(x, W):
    return tf.nn.conv2d(x, W, strides=[1,1,1,1], padding='SAME')

def max_pool_2x2(x):
    return tf.nn.max_pool(x, ksize=[1,2,2,1], strides=[1,2,2,1], padding='SAME')


# In[3]:

from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("data/", one_hot=True)


# In[4]:

def load(name):
    return np.fromfile(name, dtype=np.float32)


# In[5]:

modeldir = 'model-bnns'
model_names = ['h1w-5x5x1x32', 'h1b-32', 'h2w-5x5x32x64', 'h2b-64',
               'h3w-3136x1024', 'h3b-1024', 'h4w-1024x10', 'h4b-10']
model = [load(os.path.join(modeldir, 'model-' + n)) for n in model_names]

model[0] = model[0].reshape((32,1,5,5)).transpose((2,3,1,0))
model[2] = model[2].reshape((64,32,5,5)).transpose((2,3,1,0))
model[4] = model[4].reshape((1024,64,7,7)).transpose((2,3,1,0))
model[6] = model[6].reshape((10,1024)).transpose()


# In[6]:

x = tf.placeholder(tf.float32, [None, 784])
y_ = tf.placeholder(tf.float32, [None, 10])

x_image = tf.reshape(x, [-1, 28, 28, 1])

W_conv1 = weight_variable([5, 5, 1, 32], model[0])
b_conv1 = bias_variable([32], model[1])
h_conv1 = tf.nn.relu(conv2d(x_image, W_conv1) + b_conv1)
h_pool1 = max_pool_2x2(h_conv1)

W_conv2 = weight_variable([5, 5, 32, 64], model[2])
b_conv2 = bias_variable([64], model[3])
h_conv2 = tf.nn.relu(conv2d(h_pool1, W_conv2) + b_conv2)
h_pool2 = max_pool_2x2(h_conv2)

W_fc1 = weight_variable([7 * 7 * 64, 1024], model[4])
b_fc1 = bias_variable([1024], model[5])
h_pool2_flat = tf.reshape(h_pool2, [-1, 7*7*64])
h_fc1 = tf.nn.relu(tf.matmul(h_pool2_flat, W_fc1) + b_fc1)

W_fc2 = weight_variable([1024, 10], model[6])
b_fc2 = bias_variable([10], model[7])

y_conv = tf.nn.softmax(tf.matmul(h_fc1, W_fc2) + b_fc2)


# In[7]:

sample = mnist.test.images[0:1].copy()
actual = mnist.test.labels[0].argmax()

init = tf.initialize_all_variables()
with tf.Session() as ses:
    ses.run(init)
    predict = tf.argmax(y_conv, 1)
    recognized = ses.run(predict, feed_dict = {x: sample})

'recognized %d, actual %d' % (recognized, actual)

