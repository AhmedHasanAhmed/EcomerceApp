import mongoose from "mongoose";
import  {dburl}  from './config.js';

const conectBD = async() =>{
    try{
        await mongoose.connect(dburl,{
            useNewUrlParser: true,
            useUnifiedTopology: true

        }); 
        
        // Drop old phone index if it exists (from previous schema)
        try {
            const db = mongoose.connection.db;
            const usersCollection = db.collection('users');
            const indexes = await usersCollection.indexes();
            const phoneIndex = indexes.find(idx => idx.name === 'phone_1');
            if (phoneIndex) {
                await usersCollection.dropIndex('phone_1');
                console.log('Dropped old phone_1 index');
            }
        } catch (indexError) {
            // Index might not exist, which is fine
            console.log('No phone index to drop or already removed');
        }
        
    }catch(error) {
        console.log(`error ${error.message}`);

        process.exit(1);

    }
}
export default conectBD;
