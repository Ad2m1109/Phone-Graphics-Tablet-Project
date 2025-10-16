const net = require('net');
const robot = require('robotjs');

const PORT = 38383;
const HOST = '127.0.0.1';

console.log('Phone Graphics Tablet - PC Client (USB Mode)');
console.log('-------------------------------------------');

function connect() {
    console.log(`[Client] Attempting to connect to ${HOST}:${PORT}...`);
    const client = new net.Socket();

    client.connect(PORT, HOST, () => {
        console.log('[Client] Connected to phone server.');
    });

    let buffer = '';
    client.on('data', (chunk) => {
        buffer += chunk.toString();
        let boundary = buffer.indexOf('\n');
        while (boundary !== -1) {
            const jsonString = buffer.substring(0, boundary);
            buffer = buffer.substring(boundary + 1);
            if (jsonString) {
                processData(jsonString);
            }
            boundary = buffer.indexOf('\n');
        }
    });

    client.on('close', () => {
        console.log('[Client] Connection closed. Reconnecting in 3 seconds...');
        setTimeout(connect, 3000);
    });

    client.on('error', (err) => {
        // Error will be followed by a 'close' event, which handles reconnection.
        console.log(`[Client] Connection Error: ${err.message}`);
    });
}

function processData(jsonString) {
    try {
        const jsonData = JSON.parse(jsonString);
        const { dx, dy, mode } = jsonData;

        if (mode === 'left_click') {
            robot.mouseClick('left');
            return;
        }

        if (mode === 'right_click') {
            robot.mouseClick('right');
            return;
        }

        if (mode === 'double_click') {
            robot.mouseClick('left', true);
            return;
        }

        if (dx === undefined || dy === undefined || mode === undefined) {
            return;
        }

        const mouse = robot.getMousePos();
        const newX = mouse.x + dx;
        const newY = mouse.y + dy;

        if (mode === 'move') {
            robot.moveMouse(newX, newY);
        } else if (mode === 'draw') {
            robot.dragMouse(newX, newY);
        }
    } catch (e) {
        // Ignore JSON parsing errors for partial data
    }
}

connect();
