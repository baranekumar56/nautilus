import datetime

default_latitude = 0
default_longitude = 0  
default_Tdir = 180  
default_Tper = 12 
default_Thgt = 0.5  
default_sdir = 180  
default_sper = 12  
default_shgt = 0.5 
default_wdir = 180 
default_wper = 10  
default_whgt = 0.3 

class WeatherCell:
    def __init__(self, latitude, longitude) -> None:
        
        self.lat = float(latitude)
        self.lon = float(longitude)
        self.days = {}
        self.Tdir = []  
        self.Tper = []
        self.Thgt = []
        self.Sdir = []
        self.Sper = []
        self.Shgt = []  
        self.Wdir = [] 
        self.Wper = [] 
        self.Whgt = []  
        # self.current_days = 0
        # self.start_time = None

    def add_weather_data(self,dayTime =None, depth=None, tdir=None, tper=None, thgt=None, sdir=None, sper=None, shgt=None, wdir=None, wper=None, whgt=None):
        tdir = tdir if tdir is not None else default_Tdir # 
        tper = tper if tper is  not None else default_Tper
        thgt = thgt if thgt is not None else default_Thgt
        sdir = sdir if sdir is not None else default_sdir
        sper = sper if sper is not None else default_sper
        shgt = shgt if shgt is not None else default_shgt
        wdir = wdir if wdir is not None else default_wdir
        wper = wper if wper is not None else default_wper
        whgt = whgt if whgt is not None else default_whgt

        # if dayTime not in self.days:
        #     self.days[dayTime] = self.current_days + 1
        #     self.current_days += 1

        self.Tdir.append(tdir)
        self.Tper.append(tper)
        self.Thgt.append(thgt)
        self.Sdir.append(sdir)
        self.Sper.append(sper)
        self.Shgt.append(shgt)
        self.Wdir.append(wdir)
        self.Wper.append(wper)
        self.Whgt.append(whgt)

    
        

 