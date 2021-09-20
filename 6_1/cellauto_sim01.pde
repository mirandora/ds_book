class Worker{
  //席位置
  int s_x;
  int s_y;
  
  int x;
  int y;
  
  //会話状態。(会話中なら徐々に減衰)
  int talk_status;
  int next_talk_status;
  
  //自分かどうか
  int me;
  
  //友情（仲の良い人が2人くらいいる）
  int friend_ship;
  
  Worker(){
    talk_status = int(random(255));    
    me = 0;
    friend_ship = 0;
  }
    
  void talk(){    
    int neighbor_talk = 0;
    int side_talk = 0;
    int front_talk = 0;
    
    int neighbor_fs = 0;
    
    float talk_probability;
    
    //自分を中心に席が存在するかチェックしてもし存在するなら追加        
    for (int i = s_x-1; i<=s_x+1; i++){
      for (int j = s_y-1; j<=s_y+1; j++){
        //println(i,j,s_x,s_y,table_c,table_r);
        if ((i >= 0) && (i < table_c) && (j >= 0) && (j < table_r)){
          neighbor_talk += workers[i + j*table_c].talk_status; 
          neighbor_fs += workers[i + j*table_c].friend_ship;           
          
          //もし正面なら
          if (j == s_y){
            front_talk += workers[i + j*table_c].talk_status; 
          }
          //もし隣なら
          if (abs(s_x - i) == 1){
            side_talk += workers[i + j*table_c].talk_status; 
          }
        }
      }
    }
    
    next_talk_status = talk_status;
    
    //ルール1：周りの会話量が閾値以下になると会話終了。
    //ルール2：周りの会話量が閾値以上になると会話終了（会話に入れない）
    if ((neighbor_talk < 50) || (neighbor_talk > 500)){
      if (next_talk_status > 50){
        next_talk_status -= 50;
      }
    }    
    
    //ルール3：目の前の人、あるいは隣の人が話していたら一定確率で会話継続
    if ((side_talk > 50) || (front_talk > 50)){
      talk_probability = random(1);
      
      if ((next_talk_status < 50) && (talk_probability < 0.2)){
        next_talk_status += (side_talk + front_talk) * 0.15;
      }
    }
    
    //自分ルール
    if (me == 1){
      //ルール1：初期状態は親しい人の数で決める。
      if((frame_ct == 0) && (next_talk_status < 100)){
        next_talk_status += neighbor_fs * 25;      
      }
      if (neighbor_fs >= 1){
        //ルール2：親しい人との会話は盛り上がりに応じてネタが枯渇。        
        if(next_talk_status > neighbor_talk*0.03*neighbor_fs){
          next_talk_status -= neighbor_talk*0.03*neighbor_fs;
        }
        //ルール3：親しい人がいると一定確率で話す。
        talk_probability = random(1);
        if ((talk_probability < 0.05*neighbor_fs) && (next_talk_status < 30)){
          next_talk_status += next_talk_status * 1.5;
        }      
      }
      //ルール4：周囲に一人も親しい人がいないと話さない。
      if(neighbor_fs == 0){
        next_talk_status = 0;      
      }
      
    }  
    
  }
  
  void update(){
    talk_status = next_talk_status;    
    
    //前のtalk_statusから更新
    if (talk_status > 5){
      talk_status -=int(random(1)*5);
    }    
    
    //周りの状態に関係なく、突発的に一定確率で話す。
    float talk_probability = random(1);
    if (me != 1){
      if ((talk_probability < 0.2) && (talk_status < 50)){
        talk_status += 80;
      }
    }
    
    print(talk_status + ",");
    
  }
  
  void sitdown(int c, int r){
    s_x = c;
    s_y = r;
    
    x = c * seat_width;
    y = r * seat_width;
  }
  
  void display(){        
    fill(255-talk_status);
    
    if (me==1){ //自分
      stroke(255,0,0);
      strokeWeight(3);
    }else if(friend_ship == 1){ //仲の良い同僚
      stroke(0,0,255);
      strokeWeight(3);
    }else{ //それ以外
      stroke(0);
      strokeWeight(2);
    }
    
    rect(x+width/2-((seat_width * table_c)/2),y+height/2-((seat_width * table_r)/2),seat_width,seat_width);    
  }    
}

Worker[] workers;
//飲み会の席
int table_c = 8;
int table_r = 2;
int seat_width = 30;
int frame_ct = 0;

void setup(){
  size(640,320);  
  background(255);
  
  //16人の同僚
  workers = new Worker[table_c * table_r];
  for(int c=0;c<table_c;c++){
    for(int r=0;r<table_r;r++){
      workers[c + r*table_c] = new Worker();
      
      //自分の席を決める。
      if ((c==0) && (r ==1)){
        workers[c + r*table_c].me = 1;  
      }        

      //仲の良い同僚の席を決める。
      if (((c==3) && (r ==1)) || ((c==4) && (r ==1))){ //友人0人が近く
      //if (((c==0) && (r ==0)) || ((c==1) && (r ==1))){ //友人2人が近く
      //if (((c==1) && (r ==0)) || ((c==2) && (r ==1))){ //友人1人が近く
      //if (((c==0) && (r ==0)) || ((c==1) && (r ==1)) || ((c==1) && (r ==0))){  
        workers[c + r*table_c].friend_ship = 1;  
      }              
      
      workers[c + r*table_c].sitdown(c,r);
      workers[c + r*table_c].display();      
    }
  }  
}

void draw(){
  for(int i=0;i<workers.length;i++){
    workers[i].talk();    
    workers[i].display();    
  }
  for(int i=0;i<workers.length;i++){
    workers[i].update();    
  }  
  println("");
  frame_ct++;  
}
