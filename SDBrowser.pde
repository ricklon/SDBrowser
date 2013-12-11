/*
* Browser SD Card
 *
 *
 */
#include <SD.h>

#define MAX_INPUT 200

char gCommand[MAX_INPUT];

boolean cardInserted = false;
boolean init_SD = false;
boolean init_Vol = false;
const int chipSelect_SD_default = 27; // Change 10 to 53 for a Mega
const int chipSelect_SD = chipSelect_SD_default; // Fubarino SD ChipSelect


void setup() {
  Serial.begin(9600);
  pinMode(chipSelect_SD_default, OUTPUT);
  pinMode(chipSelect_SD, OUTPUT);
  //Disable autoenable delegate to functions
  //digitalWrite(chipSelect_SD, HIGH);
  //digitalWrite(chipSelect_SD_default, HIGH);

  delay(5000);
  Serial.println("Start"); 
  Serial.println("mount: mount card, ls: list files");
}

void printDirectory(File dir, int numTabs) {
   while(true) {

     File entry =  dir.openNextFile();
     if (! entry) {
       // no more files
       // return to the first file in the directory
       dir.rewindDirectory();
       break;
     }
     for (uint8_t i=0; i<numTabs; i++) {
       Serial.print('\t');
     }
     Serial.print(entry.name());
     if (entry.isDirectory()) {
       Serial.println("/");
       printDirectory(entry, numTabs+1);
     } else {
       // files have sizes, directories do not
       Serial.print("\t\t");
       Serial.println(entry.size(), DEC);
     }
   }
}
void processCommand(const char * command) {
	Serial.print("> ");
      if (strcmp(command, "help") == 0 || strcmp(command, "?") == 0  ) {
	Serial.println("mount, ls, unmount files.");
      }

      if (strcmp (command, "mount") == 0 ) {
        Serial.println("Mounting SD Card");
	digitalWrite(chipSelect_SD_default, HIGH);
	digitalWrite(chipSelect_SD, HIGH);
	init_SD = SD.begin(chipSelect_SD);
          if (init_SD) {
            Serial.println("Card opened.");
          } 
          else {
            Serial.println("Card failed to open.");
          }
      }
      if (strcmp (command, "unmount") == 0) {
        Serial.println("UnMounting SD Card");
        Serial.println("Cannot close and SD object. pins pulled low.");
	digitalWrite(chipSelect_SD_default, LOW);
	digitalWrite(chipSelect_SD, LOW);
      }
      if (strcmp (command, "ls") == 0) {
        Serial.println("Listing SD Card");
	File dir = SD.open("/");
        printDirectory(dir, 0);
	dir.close();
      }
      if (strcmp (command, "touch") == 0) {
        Serial.println("create file touched.txt");
	File file = SD.open("/touched.txt", FILE_WRITE);
	file.println("TOUCHED");
	file.close();
      }
      if (strcmp (command, "cat") == 0) {
        Serial.println("cat file touched.txt");
	File file = SD.open("/touched.txt");
	if (file) {	
	  while (file.available()) {
		  Serial.write(file.read());
	  }
	  file.close();
	}
      }
 } 

void processIncomingByte( const byte inByte) {
  static char buf[MAX_INPUT];
  static unsigned int ii = 0;
  Serial.print(inByte);
  //Serial.print(inByte,DEC);
  //Serial.print(":");
  switch(inByte)
  {
   case '\r': //terminator reached
    buf[ii] = 0; //terminate array
    Serial.println("");
    processCommand(buf);
    //gCommand = buf;
    //reset count
    ii = 0;
    break;
   case '\n':
     break;
   default:
     if (ii < (MAX_INPUT - 1)) {
      buf[ii++] = inByte; 
     }
     break;
  }
}


void loop() {
  if (Serial.available() > 0) {
   processIncomingByte(Serial.read());
  }
}


