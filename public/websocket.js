var ws       = new WebSocket('ws://localhost:9292/');

ws.onopen = () => {
  console.log('conectado');
};
ws.onerror = e => {
  console.log('error en la conexion', e);
};
ws.onmessage = e => {
  const msg = JSON.parse(e.data)
  document.getElementById("noti").innerHTML=msg
  

  window.createNotification({
	closeOnClick: false,
	displayCloseButton: false,
	positionClass: "nfc-top-right",
	showDuration: 5000,
	theme: "info"
	})({
	title: "Documeto nuevo",
	message: "Un nuevo documento de tu interes ha sido subido"
  });

};
ws.onclose = () => {
  console.log('desconectado');
}