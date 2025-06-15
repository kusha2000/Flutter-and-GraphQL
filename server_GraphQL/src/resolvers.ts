import { stringify } from "querystring";
import { Author, Reader, Book, Review } from "./models";
import mongoose, { Query } from "mongoose";

const resolvers = {
  Query: {
    async authors() {
      return await Author.find();
    },
    async readers() {
      return await Reader.find();
    },
    async books(_: any, { authorId }: any) {
      if (authorId) {
        return Book.find({ author: authorId }).populate("author");
      }
      return Book.find().populate("author");
    },
    async reviews(_: any, { bookId }: any) {
      if (bookId) {
        return Review.find({ book: bookId }).populate("book").populate("reader");
      }
      return Review.find().populate("book").populate("reader");
    },

    async author(_: any, { id }: any) {
      return Author.findById(id);
    },
    async book(_: any, { id }: any) {
      return Book.findById(id).populate("author");
    },
    async reader(_: any, { id }: any) {
      return Reader.findById(id);
    },
    async review(_: any, { id }: any) {
      return Review.findById(id).populate("book").populate("reader");
    },
  },

  // Add field resolvers to handle ObjectId serialization
  Author: {
    id: (parent: any) => parent._id.toString(),
    books: async (parent: any) => {
      return await Book.find({ author: parent._id });
    },
  },

  Reader: {
    id: (parent: any) => parent._id.toString(),
    reviews: async (parent: any) => {
      return await Review.find({ reader: parent._id }).populate("book").populate("reader");
    },
  },

  Book: {
    id: (parent: any) => parent._id.toString(),
    author: async (parent: any) => {
      if (parent.author && parent.author._id) {
        return parent.author; // Already populated
      }
      return await Author.findById(parent.author);
    },
    reviews: async (parent: any) => {
      return await Review.find({ book: parent._id }).populate("book").populate("reader");
    },
  },

  Review: {
    id: (parent: any) => parent._id.toString(),
    book: async (parent: any) => {
      if (parent.book && parent.book._id) {
        return parent.book; // Already populated
      }
      return await Book.findById(parent.book).populate("author");
    },
    reader: async (parent: any) => {
      if (parent.reader && parent.reader._id) {
        return parent.reader; // Already populated
      }
      return await Reader.findById(parent.reader);
    },
  },

  Mutation: {
    //add new author
    async addAuthor(_: any, args: any) {
      try {
        const { name, bio } = args;
        const author = new Author({
          name,
          bio,
          books: [],
        });

        await author.save();
        return author;
      } catch (error: any) {
        throw new Error(`Failed to add author: ${error.message}`);
      }
    },

    //add a new book under an author
    async addBook(_: any, args: any) {
      try {
        const { title, authorId } = args;

        if (!mongoose.Types.ObjectId.isValid(authorId)) {
          throw new Error("Invalid authorId format");
        }
        const validAuthorId = new mongoose.Types.ObjectId(authorId);

        const author = await Author.findById(validAuthorId);
        if (!author) {
          throw new Error("Author not found");
        }

        const book = new Book({
          title,
          author: validAuthorId,
          reviews: [],
        });

        await book.save();

        // Add book reference to author
        author.books.push(book._id);
        await author.save();

        // Return the book with populated author
        const populatedBook = await Book.findById(book._id).populate("author");
        return populatedBook;
      } catch (error: any) {
        throw new Error(`Failed to add book: ${error.message}`);
      }
    },

    //add a new review for a book
    async addReview(_: any, args: any) {
      try {
        const { bookId, readerId, content, rating } = args;

        if (!mongoose.Types.ObjectId.isValid(bookId)) {
          throw new Error("Invalid bookId format");
        }
        const validBookId = new mongoose.Types.ObjectId(bookId);

        if (!mongoose.Types.ObjectId.isValid(readerId)) {
          throw new Error("Invalid readerId format");
        }
        const validReaderId = new mongoose.Types.ObjectId(readerId);

        const book = await Book.findById(validBookId);
        if (!book) {
          throw new Error("Book not found");
        }

        const reader = await Reader.findById(validReaderId);
        if (!reader) {
          throw new Error("Reader not found");
        }

        const review = new Review({
          book: validBookId,
          reader: validReaderId,
          content,
          rating,
        });

        await review.save();

        book.reviews.push(review._id);
        await book.save();

        // Return populated review
        const populatedReview = await Review.findById(review._id)
          .populate("book")
          .populate("reader");
        return populatedReview;
      } catch (error: any) {
        throw new Error(`Failed to add review: ${error.message}`);
      }
    },
    //add a new reader
    async addReader(_: any, args: any) {
      try {
        const { name, email } = args;

        const reader = new Reader({
          name,
          email,
        });

        await reader.save();
        return reader;
      } catch (error: any) {
        throw new Error(`Failed to add reader: ${error.message}`);
      }
    },
  },
};

export default resolvers;