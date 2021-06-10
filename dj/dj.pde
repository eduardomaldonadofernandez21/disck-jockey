import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import ddf.minim.AudioRecorder;
import processing.serial.*;

boolean [] keysPressed = new boolean[5];
PImage buttonNextSong; PImage buttonBeforeSong; PImage buttonPlay; PImage buttonPause; PImage buttonStop; PImage buttonRecordPlay; PImage speedReproductor; PImage volumeImage;
boolean pantallaControl;

Minim minim;

FilePlayer filePlayer1, filePlayer2;
AudioOutput out, out2;
AudioRecorder record;

FFT audioFFT, audioFFT2;

TickRate rateControl1;
TickRate rateControl2;

float rateValue1 = 1.f;
float rateValue2 = 1.f;

int AudioRange = 101;
int Max = 100;

float Amp = 40.0;
float Index = 0.2;
float IndexAmp = Index;
float IndexStep = 0.35;

float IndexAmpRight = Index;

float[] audios = new float[AudioRange];
float[] audiosRight = new float[AudioRange];
String[] canciones = new String[6];
String[] titulosCanciones = new String[10];
String cancionActualRight;
String cancionActualLeft;

int actual,actualtemp,actual2,actualtemp2;
boolean ese = false;
boolean ese2 = false;
boolean aux = false;
boolean aux2 = false;
boolean playSongRight = false;
boolean playSongLeft = false;

float songTime1 = 0;
float songTime2 = 0;

float speedBar1 = 0;
float speedBar2 = 0;

boolean timeBarClicked1 = false;
boolean timeBarClicked2 = false;

boolean speedBarClicked1 = false;
boolean speedBarClicked2 = false;

boolean recordPlayMix = false;

Gain gainRight;
Gain gainLeft;

float volumeLeft = 0; float volumeRight = 0;
boolean controlVolume = false; //False -- Audio Right, True -- Audio Left
boolean stopSensorVol = true;
Serial myPort;  //Crea un objeto de clase serial
String val;     //Datos recibidos por el Puerto serial

void setup()
{
  size(800, 800, P3D);
  buttonNextSong = loadImage("Imagenes/next.png");
  buttonBeforeSong = loadImage("Imagenes/next.png");
  buttonPlay = loadImage("Imagenes/buttonPlay.png");
  buttonPause = loadImage("Imagenes/buttonPause.png");
  buttonStop = loadImage("Imagenes/buttonStop.png");
  speedReproductor = loadImage("Imagenes/speedReproductor.PNG");
  volumeImage = loadImage("Imagenes/volumeImage.PNG");
  noStroke();
  keysPressed[4] = true;
  pantallaControl = false;
  minim = new Minim(this);
  canciones[0] = "canciones/hablamos_mañana.mp3";
  canciones[1] = "canciones/envidiosos.mp3";
  canciones[2] = "canciones/como_se_siente.mp3";
  canciones[3] = "canciones/eminem.mp3";
  canciones[4] = "canciones/imaginedragons.mp3";
  canciones[5] = "canciones/majorlazer.mp3";
  titulosCanciones[0] = "Hablamos mañana - Bad Bunny";
  titulosCanciones[1] = "Envidiosos - Maka feat Bandaga";
  titulosCanciones[2] = "Como se siente - Jhay Cortez";
  titulosCanciones[3] = "Godzilla - Eminem";
  titulosCanciones[4] = "Cutthoart - Imagine Dragones";
  titulosCanciones[5] = "Light it up - Major Lazer";
  cancionActualLeft = "";
  cancionActualRight = "";
  
  actual = -1;
  actualtemp  = -1;
  actualtemp2 = -1;
  playSongLeft=false;
  playSongRight=false;
  
  
  speedBar1 = map(rateValue1, 0.8, 1.2 , 0, 150);
  speedBar2 = map(rateValue2, 0.8, 1.2, 0, 150);
  rateControl1 = new TickRate(rateValue1);
  rateControl2 = new TickRate(rateValue2);
  
  gainRight = new Gain(0);
  gainLeft = new Gain(0);
  
  String portName = Serial.list()[0]; 
  //cambiar 0, 1 o el que sea al número de puerto que estés usando
  myPort = new Serial(this, portName, 9600);
  
}

void draw ()
{ 
  if(!pantallaControl){
  if(recordPlayMix && record != null){
    record.beginRecord();
  }else if(record != null && record.isRecording()){
    record.endRecord();
  }
  /*if( record != null && !record.isRecording() ){
    record.beginRecord();
  }*/
  background(255);
  showDJ();
  controlVolumen();
  textSize(20);
  text(cancionActualLeft,550,545);
  text(cancionActualRight,250,545);
  if(ese){
    if(out != null){
      audioFFT.forward(out.mix);
    }
    myAudioDataUpdateRemix(); 
    fill(255,255);
    stroke(1);
    round(5);
    myAudioDataWidgetRemix(); 
  }
  textSize(18);
  fill(255);
  if(ese){
  text(calculoDuracion(filePlayer1.getMetaData().length()/1000), 250, 565);
  if(actualtemp != -1){
    cancionActualRight = titulosCanciones[actualtemp];
  }
  }
  if(ese2){
    text(calculoDuracion(filePlayer2.getMetaData().length()/1000), 550, 565);
    if(out != null){
      audioFFT.forward(out.mix);
    }
    myAudioDataUpdateRemix();
    if(actualtemp2 != -1){
      cancionActualLeft = titulosCanciones[actualtemp2];
    }
    myAudioDataWidgetRemix(); 
  }
  moveTimeBar();
  moveSpeedBar();
  selector();
  cancionactual();
  if ( myPort.available() >0){  //If data is available,  
      val = myPort.readStringUntil('\n');  //Lo guarda en val  
      if(val != null){
        volumeSensor();
      }
  }
  drawVolumeLeft();
  drawVolumeRight();
  textSize(30);
  fill(0);
  text("DJ CIU Remix Edition", 420, 25);
  textSize(15);
  fill(255);
  text("Pulse H para información de controles", 590, 670);
  }else{
    pantallaControl();
  }
}

void drawVolumeRight(){
  int posX = 725; int posY = 125;
  for(int i = 10; i<=(((volumeRight+6)/2)-1)*10;i+=10){
    fill(255);
    rect(posX,posY,20,i);
    posX -= 25;
    posY -=10;
  }
}

void drawVolumeLeft(){
  
  /*
  rect(95,125,20,10);
  rect(120,115,20,20);
  rect(145,105,20,30);
  rect(170,95, 20,40);
  rect(195, 85, 20,50);
  rect(220, 75, 20,60);
  rect(245, 65, 20,70);
  rect(270, 55, 20,80);*/
  int posX = 95; int posY = 125;
  for(int i = 10; i<=(((volumeLeft+6)/2)-1)*10;i+=10){
    fill(255);
    rect(posX,posY,20,i);
    posX += 25;
    posY -=10;
  }
 
  
  
}

void volumeSensor(){
  if(!stopSensorVol){
    if(!controlVolume){
      volumeRight =map(float(val), 25, 250, -6, 12);
      gainRight.setValue(volumeRight);
    }else{
      volumeLeft = map(float(val), 25, 250, -6, 12);
      gainLeft.setValue(volumeLeft);
    }
  }
}

String calculoDuracion(int duracion){
  String res = "";
  String resto;
  int calculoMin = duracion/60;
  int segundosResto = duracion%60;
  if(segundosResto < 10){
    resto = "0" + segundosResto;
  }else{
    resto = Integer.toString(segundosResto);
  }
  res = "Duración: " + calculoMin +  ":" + resto;
  return res;
}

void myAudioDataUpdateRemix(){
 for(int i = 0; i < AudioRange; i++){
    float tempIndexAvg = (audioFFT.getAvg(i)* Amp)*IndexAmp;
    float tempIndexCon = constrain(tempIndexAvg, 0 , Max);
    audios[i] = tempIndexCon;
    IndexAmp+= IndexStep;
 }
 IndexAmp = Index;
}

void myAudioDataUpdateRight(){
 for(int i = 0; i < AudioRange; i++){
    float tempIndexAvg = (audioFFT2.getAvg(i)* Amp)*IndexAmpRight;
    float tempIndexCon = constrain(tempIndexAvg, 0 , Max);
    audiosRight[i] = tempIndexCon;
    IndexAmpRight+= IndexStep;
 }
 IndexAmpRight = Index;
}

void myAudioDataWidgetRemix(){
  noStroke();
  fill(0,200);
  rect(0,height-112,width,102);
  for(int i = 0; i < AudioRange; i++){
     if( i%2 == 0) fill(#237D26);
     else if (i%3 == 0) fill(#80c41c);
     else fill(#ff03af);
     
     rect(10+(i*7),(height-audios[i])-11,7,audios[i]);  
  }
}

void myAudioDataWidgetRight(){
  noStroke();
  fill(0,200);
  rect(width/2,height-112,width,102);
  
  for(int i =0; i < AudioRange/2; i++){
     if( i%2 == 0) fill(#23F5EA);
     else if (i%3 == 0) fill(#FFAA29);
     else fill(#980ADE);
     rect(width-(i*5),(height-audiosRight[i])-11,4,audiosRight[i]);  
  }
}

void selector(){
  
  //Lado derecho de la lista
  stroke(100);
  fill(0);
  rect(100,590,310,20);
  textSize(14);
  fill(255);
  text(titulosCanciones[0], 215 , 597);

  
  stroke(100);
  fill(0);
  rect(100,610,310,20);
  textSize(14);
  fill(255);
  text(titulosCanciones[1], 215, 617);

  stroke(100);
  fill(0);
  rect(100,630,310,20);
  textSize(14);
  fill(255);
  text(titulosCanciones[2], 205 , 637);

  //Lado izquierdo de la lista
  stroke(100);
  fill(0);
  rect(410,590,310,20);
  textSize(14);
  fill(255);
  text(titulosCanciones[3], 475 , 597);

  
  stroke(100);
  fill(0);
  rect(410,610,310,20);
  textSize(14);
  fill(255);
  text(titulosCanciones[4], 515, 617);
  
  stroke(100);
  fill(0);
  rect(410,630,310,20);
  textSize(14);
  fill(255);
  text(titulosCanciones[5], 493, 637);


}
void reproducircancion(int i){
  if(actual == i){
    if(aux){
      playSongRight = true;
      filePlayer1.play();
      aux=false;
    }else{
      playSongRight =false;
      filePlayer1.pause();
      aux = true;
    }
  }else{
    playSongRight = true;
    if(filePlayer1 != null){
      filePlayer1.pause();
    }
    rateControl1 = new TickRate(rateValue1);
    filePlayer1 = new FilePlayer( minim.loadFileStream(canciones[i]));
    filePlayer1.play();
    if(out == null){ 
      out = minim.getLineOut();
      record = minim.createRecorder(out, "myrecording.wav");
      out.setGain(0);
    }
    filePlayer1.patch(gainLeft).patch(rateControl1).patch(out);
    audioFFT = new FFT(out.bufferSize(), out.sampleRate());
    audioFFT.linAverages(AudioRange);
    audioFFT.window(FFT.GAUSS); 
    
    actual = i;
    aux = false;
  }
  if(actual== -1){
     actual = i;  
  }
}

void reproducircancion2(int i){
   if(actual2 == i){
    if(aux2){
      playSongLeft=true;
      filePlayer2.play();
      aux2=false;
    }else{
      playSongLeft=false;
      filePlayer2.pause();
      aux2 = true;
    }
  }else{
    playSongLeft=true;
    if(filePlayer2 != null){
      filePlayer2.pause();
    }
    rateControl2 = new TickRate(rateValue2);
    filePlayer2 = new FilePlayer( minim.loadFileStream(canciones[i]));
    filePlayer2.play();
    if(out == null){ 
      out = minim.getLineOut();
      record = minim.createRecorder(out, "myrecording.wav");
    }
    filePlayer2.patch(gainRight).patch(rateControl2).patch(out);
    audioFFT = new FFT(out.bufferSize(), out.sampleRate());
    audioFFT.linAverages(AudioRange);
    audioFFT.window(FFT.GAUSS); 
    
    
    
    actual2 = i;
    aux2 = false;
  }
  if(actual2== -1){
     actual2 = i;  
  }
}

void cancionactual(){
  
  switch(actualtemp){
    case 0 :  fill(#ff0000); rect(350,590,20,20); break;
    case 1 :  fill(#ff0000); rect(350,610,20,20); break;
    case 2 :  fill(#ff0000); rect(350,630,20,20); break;
  }
  
  switch(actualtemp2){
    case 3 :   fill(#ff0000);rect(650,590,20,20); break;
    case 4 :   fill(#ff0000);rect(650,610,20,20); break;
    case 5:    fill(#ff0000);rect(650,630,20,20);break;
  }
  
}

void botonsiguiente(){
  if(ese){
    actualtemp+=1;
    if(actualtemp ==3){
      actualtemp = 0;
    }
    reproducircancion(actualtemp); 
  }
}
void botonsiguiente2(){
  if(ese2){
    actualtemp2+=1;
    if(actualtemp2 ==6){
      actualtemp2 = 3;
    }
    reproducircancion2(actualtemp2); 
   }
}
void botonanterior(){
  if(ese){
    actualtemp-=1;
    if(actualtemp ==-1){
      actualtemp = 2;
    }
    reproducircancion(actualtemp); 
  }
}
void botonanterior2(){
  if(ese2){
    actualtemp2-=1;
    if(actualtemp2 ==2){
      actualtemp2 = 5;
    }
    reproducircancion2(actualtemp2); 
  }
}
void mouseClicked(){ //220,390,

 if(mouseX > 230 && mouseX < 260 && mouseY > 390 && mouseY < 430){
    if(actualtemp < 3&& actualtemp!= -1){
        reproducircancion(actualtemp);
        ese = true;   
    }
  }
  if(mouseX > 555 && mouseX < 585 && mouseY > 390 && mouseY < 430){
    if(actualtemp2 >= 3 && actualtemp2 != -1){
        reproducircancion2(actualtemp2);
        ese2 = true;   
    }
  }
  
  
  if(mouseX > 300 && mouseX < 356  && mouseY > 390 && mouseY < 430){
    botonsiguiente();
  }
  if(mouseX > 135 && mouseX < 194  && mouseY > 390 && mouseY < 430){
    botonanterior();
  }
  if(mouseX > 470 && mouseX < 530  && mouseY > 390 && mouseY < 430){
    botonanterior2();
  }
  if(mouseX > 630 && mouseX < 690  && mouseY > 390 && mouseY < 430){
    botonsiguiente2(); 
  }
  
  
  if(mouseX > 100 && mouseX < 400 && mouseY > 590 && mouseY < 609){
      actualtemp=0; 
  }
  
  if(mouseX > 100 && mouseX < 400 && mouseY > 610 && mouseY < 629){
      actualtemp=1; 
  }
  
  if(mouseX > 100 && mouseX < 400 && mouseY > 630 && mouseY < 649){
      actualtemp=2; 
  }
  
  if(mouseX > 410 && mouseX < 710 && mouseY > 590 && mouseY < 609){
      actualtemp2=3; 
  }

  if(mouseX > 410 && mouseX < 715 && mouseY > 610 && mouseY < 629){
      actualtemp2=4; 
  }
  
  if(mouseX > 410 && mouseX < 715 && mouseY > 630 && mouseY < 659){
      actualtemp2=5; 
  }
  if(mouseX > 380 && mouseX < 435 && mouseY > 450 && mouseY < 505){
      recordPlayMix = !recordPlayMix;
  }
  

  print(mouseX+" ");
  print(mouseY+" " + "\n");
}

void mousePressed(){
  if(mouseX >= 160+songTime1 && mouseX <= 160+songTime1+10  && mouseY >= 490 && mouseY <= 490+35){
    timeBarClicked1 = true;
  }
  if(mouseX >= 490+songTime2 && mouseX <= 490+songTime2+10  && mouseY >= 490 && mouseY <= 490+35){
    timeBarClicked2 = true;
  }
  
  if(mouseX >= 378 && mouseX <= 378+25  && mouseY >= 110+speedBar1 && mouseY <= 110+speedBar1+10){
    speedBarClicked1 = true;
  }
  if(mouseX >= 418 && mouseX <= 418+25  && mouseY >= 110+speedBar2 && mouseY <= 110+speedBar2+10){
    speedBarClicked2 = true;
  }
  
}

void keyPressed(){
  if (key == '+'){
    if(!controlVolume){
      if(volumeRight < 12){
        volumeRight += 1;
      }
      gainRight.setValue(volumeRight);
    }else{
      if(volumeLeft < 12){
        volumeLeft += 1;
      }
      gainLeft.setValue(volumeLeft);
    }
  }
  if(key == '-'){
    if(!controlVolume){
      if(volumeRight > -6){
        volumeRight += -1;
      }
      gainRight.setValue(volumeRight);
    }else{
      if(volumeLeft > 6){
        volumeLeft += -1;
      }
      gainLeft.setValue(volumeLeft);
    }
  }
  
  if(key == 'v' || key == 'V'){
    controlVolume = !controlVolume;
  }
  
  if(key == 's' || key == 'S'){
    stopSensorVol = !stopSensorVol;
  }
  if(key == 'h' || key == 'H'){
    pantallaControl = !pantallaControl;
  }
}

void mouseReleased() {
  if(timeBarClicked1){
    timeBarClicked1 = false;
    if( filePlayer1 != null){
      if( filePlayer1.isPlaying()){
        jumpToTime1();
      } else{
        jumpToTime1();
        filePlayer1.pause();
      }
    }
  }
  if(timeBarClicked2){
    timeBarClicked2 = false;
    if( filePlayer2 != null){
       if( filePlayer2.isPlaying()){
        jumpToTime2();
      } else{
        jumpToTime2();
        filePlayer2.pause();
      }
    }
  }
  if(speedBarClicked1){
    speedBarClicked1 = false;
  }
  if(speedBarClicked2){
    speedBarClicked2 = false;
  }
}

void showDJ(){
  fill(40);
  rect(50,50, 700, 700);
  //Primer disco
  fill(0);
  circle(250,250, 215);
  //Circulo pequeño
  fill(#E23E12);
  circle(250,250,80);
  fill(255);
  circle(250,250,15);
  image(buttonNextSong,290,380,70,70);
  
  //Botón Play
  fill(255);
  rect(235, 400, 25, 25);
  if(!playSongRight){
    image(buttonPlay, 220,390,50,50);
  }else{
    image(buttonPause, 220,390,50,50);
  }
  
  pushMatrix();
  translate(200,450);
  rotate(PI);
  image(buttonBeforeSong,0,0,70,70);
  popMatrix();
  
  
  
  //Segundo disco
  fill(0);
  circle(575,250, 215);
   //Circulo pequeño
  fill(#E23E12);
  circle(575,250,80);
  fill(255);
  circle(575,250,15);
  image(buttonNextSong,625,380,70,70);
  
  //Botón Play
  fill(255);
  rect(560, 400, 25, 25);
  if(!playSongLeft){
    image(buttonPlay, 550,390,50,50);
  }else{
    image(buttonPause, 550,390,50,50);
  }
  
  pushMatrix();
  translate(535,450);
  rotate(PI);
  image(buttonBeforeSong,0,0,70,70);
  popMatrix();
  
  
  textSize(25);
  textAlign(CENTER,CENTER);
  fill(255);
  text("Speed", width/2+8,70);
  //BPM
  fill(255);
  rect(370, 100, 80,180);
  //1ºDisco
  fill(20);
  rect(385,110, 10, 160);
  fill(#D9D8D7);
  rect(378,110+speedBar1,25,10);
  
  //2º Disco
  fill(20);
  rect(425,110, 10, 160);
  fill(#D9D8D7);
  rect(418,110+speedBar2,25,10);
  
  //Botón grabación mezcla
  if(recordPlayMix){
    fill(#cc0000);
    circle(410,480,60);
    fill(255);
    circle(410,480,50);
    fill(#cc0000);
    circle(410,480,40);
  }else{
    fill(0);
    circle(410,480,60);
    fill(#e3e4e5);
    circle(410,480,50);
    fill(#cc0000);
    circle(410,480,25);
  }
  
}

void controlVolumen(){
  //Volumen 1º Audio
  fill(0);
  rect(160,500, 180, 10);
  fill(#D9D8D7);
  if( filePlayer1 != null && filePlayer1.isPlaying()  && !timeBarClicked1){
    songTime1 = map( filePlayer1.position(), 0, filePlayer1.length(), 0, 170 );
  }
  rect(160+songTime1,490,10,35);
  
  //Volumen 2º Audio
  fill(0);
  rect(490,500, 180, 10);
  fill(#D9D8D7);
  if( filePlayer2 != null && filePlayer2.isPlaying() && !timeBarClicked2){
    songTime2 = map( filePlayer2.position(), 0, filePlayer2.length(), 0, 170 );
  }
  rect(490+songTime2,490,10,35);
}


void moveTimeBar(){
   if(timeBarClicked1){
     songTime1 = mouseX - 160;
     if(mouseX -160 > 170){
       songTime1 = 170;
     }else if(mouseX < 160){
       songTime1 = 0;
     }
   }
   
   if(timeBarClicked2){
     songTime2 = mouseX - 490;
     if(mouseX - 490 > 170){
       songTime2 = 170;
     }else if(mouseX < 490){
       songTime2 = 0;
     }
   }
}

void moveSpeedBar(){
   if(speedBarClicked1){
     speedBar1 = mouseY - 110;
     if(mouseY > 260){
       speedBar1 = 150;
     }else if(mouseY < 110){
       speedBar1 = 0;
     }
     rateValue1 = map(speedBar1,0,150,0.8,1.2);
     rateControl1.value.setLastValue(rateValue1);
   }
   
   if(speedBarClicked2){
     speedBar2 = mouseY - 110;
     if(mouseY > 260){
       speedBar2 = 150;
     }else if(mouseY < 110){
       speedBar2 = 0;
     }
     rateValue2 = map(speedBar2,0,150,0.8,1.2);
     rateControl2.value.setLastValue(rateValue2);
   }
}

void jumpToTime1(){
  float time = map( songTime1, 0, 170, 0, filePlayer1.length());
  filePlayer1.play((int)time);
}

void jumpToTime2(){
  float time = map( songTime2, 0, 170, 0, filePlayer2.length());
  filePlayer2.play((int)time);
}

void pantallaControl(){
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0); 
  background (#e3e4e5) ;
  textSize(50);
  textAlign(CENTER,CENTER);
  fill(0);
  text("DJ Remix", width/2,75);
  textSize(18);
  textAlign(LEFT);
  image(buttonNextSong,50,200,70,70);
  text("Se cambia al siguiente audio", 130, 240);
  
  //image(buttonBeforeSong,50,250,70,70);
  
  //text("Se cambia al audio anterior", 130,320);
  fill(255);
  rect(70, 310, 40, 40);
  image(buttonPlay, 50,300,70,70);
  fill(0);
  text("Reproducir el audio", 130,340);
  fill(255);
  rect(70, 410, 40, 40);
  image(buttonPause, 50,400,70,70);
  fill(0);
  text("Pausar el audio", 130,440);
  
  fill(0);
  circle(80,520,60);
  fill(255);
  circle(80,520,50);
  fill(#cc0000);
  circle(80,520,25);
  fill(0);
  text("Grabar la mezcla", 130,530);
  
  fill(#cc0000);
  circle(80,600,60);
  fill(255);
  circle(80,600,50);
  fill(#cc0000);
  circle(80,600,40);
  fill(0);
  text("Parar la mezcla", 130,610);
  
  image(speedReproductor, 450,200, 40,120);
  text("Cambia la velocidad de\n         los audios", 495, 240);
  
  fill(0);
  rect(375,380, 180, 10);
  fill(#D9D8D7);
  rect(465,370,10,35);
  fill(0);
  text("Línea del tiempo del audio", 495, 410);
  
  image(volumeImage, 380,450, 170,85);
  text("Volumen controlado\n por sensor de distancia", 560,500);
  
  text("*Tecla S: Activar/Desactivar el sensor de distancia", 350, 610);
  
  text("*Tecla V: Cambiar el control de volumen\n al otro audio", 350, 650);
 
  fill(0);
  textAlign(CENTER);
  textAlign(LEFT);
  textSize(20);
  text("© Eduardo Maldonado Fernández\n    Fernando Marcelo Alonso\n    Marcos Couros García",40,height-90);

}
