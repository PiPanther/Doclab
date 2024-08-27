 const jwt = require("jsonwebtoken");
const authRouter = require("../routes/auth");

const auth = async (req, res, next) => {
    try {
        const token = req.header("x-auth-token");
        if(!token) {
            return res.status(401).json({msg : "Access Denied, No auth token"});

        }

        const verified = jwt.verify(token, "passwordKey");

        if(!verified) {
            return res.status(401).json({msg : "Token Verification failed, try again later"});
        }

        req.user = verified.id;
        req.token = token;
        next();

    } catch (e) {
        res.status(500).json({error : e.message});
    }
}

module.exports = auth;