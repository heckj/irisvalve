# -*- coding: utf-8 -*-
from django.test import TestCase
from google.appengine.ext import db
from irisvalve.models import Tile, MapLocation

class TileTest(TestCase):
	def test_nothing(self):
		self.assertTrue(1)
	def setUp(self):
		Tile(image='http://www.foo.com/open.png',name='open').put()
		Tile(image='http://www.foo.com/blocked.png',name='blocked').put()
	def test_setup(self):
		self.assertEquals(2,len(Tile.all()))
		self.assertEquals(1,len(Tile.all().filter('name =','open')))
		self.assertEquals(1,len(Tile.all().filter('name =','blocked')))
		open = Tile.all().filter('name =','open')[0]
		MapLocation(tile=open,x=0,y=0).put()
		self.assertEquals(1,len(MapLocation.all()))

class BasicTileTest(TestCase):
	def test_basic_create(self):
		#clear all tiles
		for obj in Tile.all():
			x.delete()
		x = Tile(image='http://www.foo.com/',name='foo')
		x.put()
		self.assertEquals(1,len(Tile.all()))
		x.delete()
		self.assertEquals(0,len(Tile.all()))

class MapTileTest(TestCase):
	def setUp(self):
		open = Tile(image='http://www.foo.com/open.png',name='open')
		open.put()
		blocked = Tile(image='http://www.foo.com/blocked.png',name='blocked')
		blocked.put()
		for x in range(10):
			for y in range(10):
				MapLocation(tile=open,x=x,y=y).put()
	def test_setup(self):
		self.assertEquals(100,len(MapLocation.all()))