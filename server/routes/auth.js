const express = require("express");
const User = require("../models/user");
const jwt = require("jsonwebtoken");
const auth = require("../middlewares/auth");

const authRouter = express.Router();


authRouter.post("/api/signup/", async (request, response) => {
    try {
        const {name, email, profilePic} =  request.body;
        
        let user = await User.findOne({
           email
        });
        
        if(!user) {
            user = new User({
                email : email,
                name : name,
                profilePic : profilePic,
            })

            user = await user.save();
        }
        const token = jwt.sign({id : user._id}, "passwordKey");
        response.status(200).send({user, token});
        

    } catch (e)  {
        console.log(e);
        response.status(500).send({error : e.message});
        
    }
})

authRouter.get('/', auth, async (request, reponse) => {
    const user = await User.findById(request.user);
    reponse.json({user, token: request.token})
})

module.exports = authRouter;