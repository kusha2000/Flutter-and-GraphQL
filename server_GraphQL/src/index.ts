import express, { Application } from "express";
import mongoose from "mongoose";
import { ApolloServer } from "@apollo/server";
import { startStandaloneServer } from "@apollo/server/standalone";
import schema from "./schema"; 
import resolvers from "./resolvers";
import cors from "cors";

const app: Application = express();
const PORT = parseInt(process.env.PORT || "4000", 10);

// Middleware
app.use(express.json());
app.use(cors());

// Connect to MongoDB
mongoose
  .connect("mongodb://localhost/bookstore")
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.log(err));

// Create an instance of ApolloServer
const server = new ApolloServer({
  typeDefs: schema,
  resolvers,
});

// Start the standalone server
startStandaloneServer(server, {
  listen: { port: PORT },
}).then(({ url }) => {
  console.log(`🚀 Server ready at ${url}`);
});
