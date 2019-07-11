//This Macro opens the raw images and processes them into SRRF imagess

//Set these paramenters
//Number of slices in the Z Stack
nrSlices = 12;
//Number of images to be converted into a SRRF image
nrImagesPerSlice = 99;

//Root directory containing the raw data
dir = "C:/Users/RFG Lab/Desktop/Hand_GFPmoe/Raw/";

//Directory to save the SRRF images
SRRFdir = "C:/Users/RFG Lab/Desktop/Hand_GFPmoe/SRRF/"

//Directory to save the average intensity of the raw data
Avdir = "C:/Users/RFG Lab/Desktop/Hand_GFPmoe/Average/"

//Set the SRRF parameters below
ringSize = 0.5;
radMag = 5;
axes = 8

////////////////////////////////////////////////////////
//Get the number of frames in the folder
list = getFileList(dir);
nrFrames = list.length;


start = getTime();

//Open each frame one by one
for(frame = 0; frame < nrFrames; frame++){

	//Make a directory to save each frame
	File.makeDirectory(SRRFdir + "frame" + frame + "/");

	
	//Make a directory to save each frame for the average of the image
	File.makeDirectory(Avdir + "frame" + frame + "/");

	//Open all the images of one frame
	run("Image Sequence...", "open=[" + dir + "frame" + frame + "/Pos0/img_000000000_Default0_001.tif] sort");
	
	//Take the entire stack and split it into substacks that contain each of the slices
	for(slice=0; slice < nrSlices; slice++){

		//Calculate the first and last index of the slice
		first = 1+nrImagesPerSlice*slice;
		last = nrImagesPerSlice*(slice+1);

		//Make and save the substack
		run("Make Substack..."	, " slices=" + first + "-" + last);

		//Run NanoJ-SRRF on the substack and save it in the SRRF Directory
		run("SRRF Analysis", "ring="+ringSize+" radiality_magnification=" +radMag+" axes="+axes+" frames_per_time-point=0 start=0 end=0 max=100 preferred=0");
		saveAs("Tiff", SRRFdir + "frame" + frame + "/slice" + slice +".tif");

		//Close SRRF image and raw image stack
		close();

		//Run Average Projection on the substack and save it in the Average Directory
		run("Z Project...", "projection=[Average Intensity]");
		saveAs("Tiff", Avdir + "frame" + frame + "/slice" + slice +".tif");
		close();
		close();
	}

	//Now that we finished making substacks, close the frame
	close();
}

//Now we need to concatenate each frame into an individual stack
//Add a directory to save each frame in
File.makeDirectory(SRRFdir + "AllFrames/");


for(frame = 0; frame < nrFrames; frame++){

	//Open all the images of one frame and save as a stack
	run("Image Sequence...", "open=[" + SRRFdir + "frame" + frame + "/slice0.tif] sort");
	saveAs("Tiff", SRRFdir + "AllFrames/" + "n1_t" + frame + ".TIF");

	//Close SRRF Stack
	close();
}

//And do the same for the average intensity reconstruction
File.makeDirectory(Avdir + "AllFrames/");
//Open each frame one by one
for(frame = 0; frame < nrFrames; frame++){

	//Open all the images of one frame and save as a stack
	run("Image Sequence...", "open=[" + Avdir + "frame" + frame +"/slice0.tif] sort");
	saveAs("Tiff", Avdir + "AllFrames/" + "n1_t" + frame + ".TIF");

	//Close SRRF Stack
	close();
}

itTook = getTime() - start;
print(itTook)
