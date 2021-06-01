import peasy.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

boolean [] keysPressed = new boolean[5];
PImage buttonNextSong; PImage buttonBeforeSong; PImage buttonPlay; PImage buttonPause; PImage buttonStop;
boolean pantallaControl;

Minim minim;
AudioPlayer cancion, cancion2;
FFT audioFFT, audioFFT2;

int AudioRange = 101;
int Max = 100;

float Amp = 40.0;
float Index = 0.2;
float IndexAmp = Index;
float IndexStep = 0.35;

float[] audios = new float[AudioRange];
String[] canciones = new String[5];
int actual,actualtemp,actual2,actualtemp2;
boolean ese = false;
boolean ese2 = false;
boolean aux = false;
boolean aux2 = false;
boolean playSongRight = false;
boolean playSongLeft = false;

boolean counting=false;
int countingBeginning,countingEnd;
float record;

void setup()
{
  size(800, 800, P3D);
  buttonNextSong = loadImage("Imagenes/next.png");
  buttonBeforeSong = loadImage("Imagenes/next.png");
  buttonPlay = loadImage("Imagenes/buttonPlay.png");
  buttonPause = loadImage("Imagenes/buttonPause.png");
  buttonStop = loadImage("Imagenes/buttonStop.png");
  noStroke();
  keysPressed[4] = true;
  pantallaControl = true;
  minim = new Minim(this);
  canciones[0] = "canciones/hablamos_mañana.mp3";
  canciones[1] = "canciones/envidiosos.mp3";
  canciones[2] = "canciones/como_se_siente.mp3";
  canciones[3] = "canciones/eminem.mp3";
  canciones[4] = "canciones/imaginedragons.mp3";
  actual = -1;
  actualtemp  = -1;
  actualtemp2 = -1;
  playSongLeft=false;
  playSongRight=false;
}

void draw ()
{ 
  background(255);
  showDJ();
  controlVolumen();
  text("Pista 1: ",145,620);
  text("Pista 2: ",460,620);
  if(ese){
    audioFFT.forward(cancion.mix);
    myAudioDataUpdate(); 
    fill(255,255);
    stroke(1);
    round(5);
    myAudioDataWidget(); 
    textSize(22);
    fill(255);
    if(ese)text("Reproduciendo: "+canciones [actual] +", duración: "  + cancion.getMetaData().length()/1000, 150, 650);
    if(ese2)text("Reproduciendo: "+canciones[actual2] +", duración: " + cancion2.getMetaData().length()/1000, 450, 650);
  }
  selector();
  cancionactual();
}


void myAudioDataUpdate(){
 for(int i = 0; i < AudioRange; i++){
    float tempIndexAvg = (audioFFT.getAvg(i)* Amp)*IndexAmp;
    float tempIndexCon = constrain(tempIndexAvg, 0 , Max);
    audios[i] = tempIndexCon;
    IndexAmp+= IndexStep;
 }
 IndexAmp = Index;
}

void myAudioDataWidget(){
  noStroke();
  fill(0,200);
  rect(0,height-112,width,102);
  
  for(int i = 0; i < AudioRange; i++){
     if( i%2 == 0) fill(#237D26);
     else if (i%3 == 0) fill(#80c41c);
     else fill(#ff03af);
     
     rect(10+(i*5),(height-audios[i])-11,4,audios[i]);  
  }
}
void selector(){
  
  stroke(100);
  fill(0);
  rect(100,540,310,20);
  textSize(14);
  fill(255);
  text("Bad Bunny", 135 , 547);

  
  stroke(100);
  fill(0);
  rect(100,560,310,20);
  textSize(14);
  fill(255);
  text("Maka", 135, 567);

  stroke(100);
  fill(0);
  rect(100,580,310,20);
  textSize(14);
  fill(255);
  text("Jhay Cortez", 138 , 587);

  
  stroke(100);
  fill(0);
  rect(410,540,310,20);
  textSize(14);
  fill(255);
  text("Eminem", 443 , 547);

  
  stroke(100);
  fill(0);
  rect(410,560,310,20);
  textSize(14);
  fill(255);
  text("Imagine Dragons", 475, 567);


}
void reproducircancion(int i){
  if(actual == i){
    if(aux){
      playSongRight = true;
      cancion.play();
      aux=false;
    }else{
      playSongRight =false;
      cancion.pause();
      aux = true;
    }
  }else{
    playSongRight = true;
    if(ese) cancion.close();
    cancion = minim.loadFile(canciones[i]);
    audioFFT = new FFT(cancion.bufferSize(), cancion.sampleRate());
    audioFFT.linAverages(AudioRange);
    audioFFT.window(FFT.GAUSS);  
    cancion.play();
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
      cancion2.play();
      aux2=false;
    }else{
      playSongLeft=false;
      cancion2.pause();
      aux2 = true;
    }
  }else{
    playSongLeft=true;
    if(ese2) cancion2.close();
    cancion2 = minim.loadFile(canciones[i]);
    audioFFT2 = new FFT(cancion2.bufferSize(), cancion2.sampleRate());
    audioFFT2.linAverages(AudioRange);
    audioFFT2.window(FFT.GAUSS);  
    cancion2.play();
    actual2 = i;
    aux2 = false;
  }
  if(actual2== -1){
     actual2 = i;  
  }
}

void pararcancion(int i){
  if(actual == i){
    cancion.close();
    aux = false;
    actual =-1;
  }
}
void cancionactual(){
  
  switch(actualtemp){
    case 0 :  fill(#ff0000); rect(250,540,20,20); break;
    case 1 :  fill(#ff0000); rect(250,560,20,20); break;
    case 2 :  fill(#ff0000); rect(250,580,20,20); break;
  }
  
  switch(actualtemp2){
    case 3 :   fill(#ff0000);rect(650,540,20,20); break;
    case 4 :   fill(#ff0000);rect(650,560,20,20); break;
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
  if(ese){
    actualtemp2+=1;
    if(actualtemp2 ==5){
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
  if(ese){
    actualtemp2-=1;
    if(actualtemp2 ==2){
      actualtemp2 = 4;
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
  
  
  if(mouseX > 100 && mouseX < 400 && mouseY > 540 && mouseY < 560){
      actualtemp=0; 
  }
  
  if(mouseX > 100 && mouseX < 400 && mouseY > 560 && mouseY < 580){
      actualtemp=1; 
  }
  
  if(mouseX > 100 && mouseX < 400 && mouseY > 580 && mouseY < 600){
      actualtemp=2; 
  }
  
  if(mouseX > 410 && mouseX < 710 && mouseY > 540 && mouseY < 560){
      actualtemp2=3; 
  }

  if(mouseX > 410 && mouseX < 715 && mouseY > 560 && mouseY < 580){
      actualtemp2=4; 
  }

  print(mouseX+" ");
  print(mouseY+" " + "\n");
}

void stop(){
  cancion.close();
  minim.stop();
  super.stop();
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
  text("Speed", width/2,70);
  //BPM
  fill(255);
  rect(370, 100, 80,180);
  //1ºDisco
  fill(20);
  rect(385,110, 10, 160);
  fill(#D9D8D7);
  rect(378,165,25,10);
  
  //2º Disco
  fill(20);
  rect(425,110, 10, 160);
  fill(#D9D8D7);
  rect(418,205,25,10);
  
}

void controlVolumen(){
  //Volumen 1º Audio
  fill(0);
  rect(160,500, 180, 10);
  fill(#D9D8D7);
  rect(260,490,10,35);
  
  //Volumen 2º Audio
  fill(0);
  rect(490,500, 180, 10);
  fill(#D9D8D7);
  rect(560,490,10,35);
  
}




void pantallaControl(){
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0); 
  background (0) ;
  textSize(50);
  textAlign(CENTER,CENTER);
  fill(255);
  text("Estructura 3D: Despacho", width/2,100);
  textSize(25);
  textAlign(CENTER);
  text("Para visualizar el entorno pulse la tecla C", width/2, 290);
  textAlign(CENTER);
  text("*Tecla UP: Modo vista desde el techo\n*Tecla DOWN: Modo vista desde el suelo\n*Tecla RIGHT: Modo vista desde la esquina\n*Tecla LEFT: Modo vista desde la mesa\n*Tecla R: Resetear la vista desde el modo por defecto", width/2, 330);
  textSize(20);
  text("© Eduardo Maldonado Fernández",width-400,height-10);

}
