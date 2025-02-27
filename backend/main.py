from fastapi import FastAPI, File, UploadFile, HTTPException
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorGridFSBucket
from bson import ObjectId
from fastapi.responses import StreamingResponse
import io

app = FastAPI()

# MongoDB Connection (with motor)
MONGO_URI = "mongodb+srv://nutriscan:nutriscan@cluster0.fuano.mongodb.net/nutriscan?retryWrites=true&w=majority"
client = AsyncIOMotorClient(MONGO_URI)
db = client["medical_reports"]

# Use motor's async GridFSBucket
fs = AsyncIOMotorGridFSBucket(db)

@app.post("/upload/")
async def upload_file(file: UploadFile = File(...)):
    file_id = await fs.upload_from_stream(file.filename, file.file)
    return {"message": "File uploaded", "file_id": str(file_id)}

@app.get("/files/")
async def list_files():
    files = []
    async for grid_out in fs.find({}):
        files.append({
            "id": str(grid_out._id),
            "name": grid_out.filename
        })
    return files


@app.get("/download/{file_id}")
async def download_file(file_id: str):
    try:
        grid_out = await fs.open_download_stream(ObjectId(file_id))

        # Read the file into memory (optional, can stream directly in bigger projects)
        file_data = await grid_out.read()

        return StreamingResponse(io.BytesIO(file_data), media_type="application/octet-stream",
                                 headers={"Content-Disposition": f"attachment; filename={grid_out.filename}"})
    except Exception:
        raise HTTPException(status_code=404, detail="File not found")

@app.delete("/delete/{file_id}")
async def delete_file(file_id: str):
    await fs.delete(ObjectId(file_id))
    return {"message": "File deleted"}

