from flask import Flask, render_template,request,json
from flask_cors import CORS
from gridGeneration.gridGen import *
# Setting up the application 
app = Flask(__name__) 
CORS(app)
# making route 
  
@app.route('/')
def home():
    return render_template('index.html')

@app.route('/submit',methods=['POST']) 
def ship(): 
    data = request.json
    t = time.time()
    path_lat_lon1 = grid.a_star(data['start_latitude'], data['start_longitude'], data['end_latitude'], data['end_longitude'], 0, data['speed'], True)
    print('total time',time.time() - t)
    return json.dumps({'intermediete_points':path_lat_lon1})
# running application 
if __name__ == '__main__':
    grid = Grid()
    app.run(port=5500, debug=True)