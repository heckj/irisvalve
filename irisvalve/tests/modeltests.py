# -*- coding: utf-8 -*-
from django.db.models import signals
from django.test import TestCase
from google.appengine.ext import db
from datetime import datetime
from irisvalve.models import Tile, MapLocation

class SampleTest(TestCase):
	def test_nothing(self):
		self.assertTrue(1)

class SampleTest2(TestCase):
	def test_nothing2(self):
		self.assertTrue(1)

class TileTest(TestCase):
	def test_basic_create(self):
		#clear all tiles
		for obj in Tile.all():
			x.delete()
		x = Tile(image='http://www.foo.com/',name='foo')
		x.put()
		self.assertEquals(1,len(Tile.all()))
		x.delete()
		self.assertEquals(0,len(Tile.all()))