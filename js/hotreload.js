
const socket = new WebSocket('ws://localhost:7575');

socket.onmessage = (event) => {
  if (event.data === 'reload') {
    window.location.reload();
    console.log('reloading')
  }
};

socket.onopen = () => {
  console.log('Connected to WebSocket server');
};

socket.onerror = (error) => {
  console.log('Error occurred:', error);
};

socket.onclose = () => {
  console.log('Disconnected from WebSocket server');
};
