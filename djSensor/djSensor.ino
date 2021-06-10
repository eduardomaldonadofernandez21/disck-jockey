int analogPin = 0; // potentiometer connected to analog pin 3
int val = 0;
int iter = 0;
float total = 0;

void setup() {
  Serial.begin(9600);
  pinMode(9,OUTPUT);

}

void loop() {
  val = analogRead( analogPin );
  if(iter < 500){
    total += val;
  }else{
    Serial.println(round(total/1200));
    total = 0;
    iter = 0;
  } 
  iter++;

}
