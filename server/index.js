const express = require("express")
const mongoose = require("mongoose")
const authRouter = require("./routes/auth")
const cors = require("cors");
const http = require("http");


const documentRouter = require("./routes/document")
const PORT = process.env.PORT | 3001

const app = express()
var server = http.createServer(app);
var io = require("socket.io")(server);

const db = "mongodb+srv://ashishSDE:Ds1e3Buv8r9sYsm2@cluster0.c2ylp.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(documentRouter);


mongoose.connect(db).then(
    console.log("connection successful")
).catch( (e) => {
    console.log('e')
})

io.onconnection((socket) => {
    console.log("Connected  " + socket.id)
})

app.listen(PORT, "0.0.0.0", () => {
    console.log(`connected at port ${PORT}`)
    
    
});