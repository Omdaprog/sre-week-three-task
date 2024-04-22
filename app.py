from flask import Flask, request
import threading
import time
import atexit
import os
import signal

app = Flask(__name__)

@app.route('/')
def hello_world():
  return 'Stripe Portal is up!'

def shutdown():
  try:
    time.sleep(10)
    func = request.environ.get('werkzeug.server.shutdown')
    if func is not None:
      func()
  except RuntimeError:  # Handle exception if no request context
    print("Shutdown failed due to missing request context")
    os.kill(os.getpid(), signal.SIGTERM)  # Alternative shutdown method

shutdown_thread = threading.Thread(target=shutdown)
shutdown_thread.start()

def shutdown_on_exit():
  shutdown_thread.join(1)  # Wait for shutdown thread to finish

atexit.register(shutdown_on_exit)

if __name__ == '__main__':
  app.run(debug=True, host="0.0.0.0", port=5003)  # Listen on all interfaces, port 5000