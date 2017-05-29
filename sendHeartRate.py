import bitalino
import sys
import signal
from biosppy.signals import ecg
from biosppy.signals import eda
from biosppy.signals import tools
import random
import time
import numpy as np

from threading import *
import select

# import argparse
# from pythonosc import osc_message_builder
# from pythonosc import udp_client
from OSC import OSCClient, OSCMessage

#   .... Bitalino Setup ....
SamplingRate = 1000
nSample=10

device = bitalino.BITalino("/dev/tty.bitalino-DevB")#/dev/tty.BITalino-58-82-DevB")
#device = bitalino.BITalino("20:15:10:26:62:92")
device.start(SamplingRate)
#   ........

#   .... Sockets Setup....
# parser = argparse.ArgumentParser()
# parser.add_argument("--ip", default="127.0.0.1", help="The ip of the OSC server")
# parser.add_argument("--port", type=int, default=5204, help="The port the OSC server is listening on")
# args = parser.parse_args()
#
# processing = udp_client.SimpleUDPClient(args.ip, args.port)

processing = OSCClient()
processing.connect( ("127.0.0.1", 5204) )

time_send = time.time()
#   ........

#   .... EXIT ....
def signal_handler(signum, frame):
    id_time = str(int(time.time()))
    ecg.ecg(signal = participant1.ecg_data, sampling_rate = SamplingRate, show=False)
    np.savetxt('files/biosppy_bitalino/biotetris_mainECG1_' + id_time + '.txt', participant1.data_file, fmt="%s")

    ecg.ecg(signal = participant2.ecg_data, sampling_rate = SamplingRate, show=False)
    np.savetxt('files/biosppy_bitalino/biotetris_mainECG2_' + id_time + '.txt', participant2.data_file, fmt="%s")

    print('END OF EXPERIMENT')
    sys.exit(0)
#   ........

#   .... CLASSES ....
class ParticipantData(object):
    def __init__(self, samplingRate, participant):
        self.id = participant
        self.samplingRate = samplingRate
        self.ecg_data = np.array([])
        self.hr = np.array([])
        self.data_file = ""

    def processECG(self, ecgBitalino):
        self.ecg_data = np.append(self.ecg_data, float(ecgBitalino))
        self.data_file = np.append(self.data_file, millis + " " + ecgBitalino + " 0")

        if (self.ecg_data.size % 10 == 0):
            print "ecg "+str(self.id)+": " + str(self.ecg_data.size)

        if (self.ecg_data.size % 2000 == 0 and self.ecg_data.size > 3000):
            self.hr = np.append(self.hr, self.getHeartRate(self.ecg_data))
            print "gethr "+str(self.id)+": "+str(self.hr[self.hr.size-1])
            # print "len baseline: "+str(self.hr_baseline)

        if len(self.hr) > 50:
            print "hr len "+str(self.id)+" > 50"

    def getHeartRate(self, data_ecg):
#        if (data_ecg.size % 2000 == 0 and data_ecg.size > 3000):
        ts_ecg, filtered_ecg, rpeaks, templates_ts, templates, heart_rate_ts, heart_rate= ecg.ecg(
            signal = data_ecg,
            sampling_rate = SamplingRate,
            show = False)

        #print "hr "+self.id+": len --> " + str(len(heart_rate)) + " val --> " + str(heart_rate[len(heart_rate) - 1])
        return heart_rate

#   ........


participant1 = ParticipantData(SamplingRate, 1)
participant2 = ParticipantData(SamplingRate, 2)
#   ........


while True:
    # --- Bitalino ---
    millis = time.clock()
    millis = format(millis, '.3f')
    millis = str(millis)

    dataAcquired = device.read(nSample)

    SeqN = dataAcquired[0, 4:8]
    SeqN = str(SeqN)
    physio_data = SeqN.split()

    ecgBitalino = physio_data[2]
    participant1.processECG(ecgBitalino)

    ecgBitalino = physio_data[3]
    participant2.processECG(ecgBitalino)
    # ------


    if time.time() - time_send >= 0.5:
        #print("SEND MESSAGE")
        if (participant1.hr.size > 1 and participant2.hr.size > 1):
            print("SEND MESSAGE")
            msg = OSCMessage("/hr/" + str(int(participant1.hr[len(participant1.hr) - 1])) + "/" + str(int(participant2.hr[len(participant2.hr) - 1])))
            processing.send(msg)

        time_send = time.time()