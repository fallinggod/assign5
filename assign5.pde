PImage bg1,bg2,enemy,fighter,hp,treasure,start1,start2,end1,end2,shoot;
PImage[] flames=new PImage[5];
int enemyCount = 8;
//hp
float Hp=197;//total hp
float hpX;
//figther
float ftx,fty;
float fSpeed;
//treasure
float tx,ty;
//bg
int bgx1,bgx2;
//enemy
int[] enemyX = new int[enemyCount];
int[] enemyY = new int[enemyCount];
//flame
int[] currentFrame=new int[8];
float[] fx=new float[8];
float[] fy=new float[8];
//shoot
float[] sx=new float[8];
float[] sy=new float[8];
float sSpeed;
int closestEnemy;
//state
int GameState;
int EnemyState;
//score
int count;
final int GAME_START=0;
final int GAME_RUN=1;
final int GAME_OVER=2;
final int ENEMY_RUN1=0;
final int ENEMY_RUN2=1;
final int ENEMY_RUN3=2;
//boolean
boolean up=false,down=false,right=false,left=false;
boolean []enemyDestory=new boolean[8];
boolean []flamesAppear=new boolean[8];
boolean treasureHit=false;
boolean enemyHit=false;
boolean bulletHit=false;
void setup () {
    size(640,480);
    //image
    start1=loadImage("img/start1.png");
    start2=loadImage("img/start2.png");
    bg1=loadImage("img/bg1.png");
    bg2=loadImage("img/bg2.png");
    treasure=loadImage("img/treasure.png");
    fighter=loadImage("img/fighter.png");
    enemy=loadImage("img/enemy.png");
    hp=loadImage("img/hp.png");  
    end1=loadImage("img/end1.png");
    end2=loadImage("img/end2.png");
    shoot=loadImage("img/shoot.png");
    for(int i=0;i<5;i++)
    {
       flames[i]=loadImage("img/flame"+(i+1)+".png");
    }
    //hp
    hpX=Hp/5;
    //speed
    fSpeed=5;
    sSpeed=4;
    //fighter
    ftx=width-61;
    fty=height/2;
    //bg
    bgx1=641;
    bgx2=0;
    //treasure
    tx=random(41,601);
    ty=random(41,441);
    //state
    GameState=0;
    EnemyState=ENEMY_RUN1;
    //score
    count=0;
    //
    for(int i=0;i<8;i++)
    {
      enemyDestory[i]=false;
      flamesAppear[i] = false;
      currentFrame[i] = 0;
    }
    for(int i=0;i<5;i++)
    {
      sx[i]=-960;
      sy[i]=-960;
    }
 
}

void draw()
{
  switch(GameState)
  {
    case GAME_START:
    {
      image(start2,0,0);  
      if(mouseX>207&&mouseX<454) //x:207-454,y:378-413
      {
        if(mouseY>378&&mouseY<413)
        {
          image(start1,0,0);
          if(mousePressed)
          {
             GameState=GAME_RUN;
              addEnemy(0);
              count=0;
          }
        }
      }
      break;
    }
    //------------------------------------------------------
    case GAME_RUN:
    {
      //bg
      image(bg1,bgx1-640,0);
      bgx1+=3;
      bgx1%=1280;
      image(bg2,bgx2-640,0);
      bgx2+=3;
      bgx2%=1280;
      //treasure
      image(treasure,tx,ty);
      treasureHit=isHit(tx,ty,41,41,ftx,fty,51,51);
      if(treasureHit)
      {
         tx=random(41,601);
         ty=random(41,441);
         hpX+=Hp/5; 
      }
      //fighter move
      if(up)
        fty-=fSpeed;
      if(down)
        fty+=fSpeed;
      if(right)
        ftx+=fSpeed;
      if(left)
        ftx-=fSpeed;
      //boundary detection
      if(ftx<0)
        ftx=0;
      if(ftx>590)
        ftx=590;
      if(fty<0)
        fty=0;
      if(fty>429)
        fty=429;
      image(fighter,ftx,fty);
      //hp
      if(hpX<=0)
      {
        hpX=0;
        GameState=GAME_OVER;
      }
      if(hpX>Hp)
      hpX=Hp;
      fill(255,0,0);
      rect(41,23,hpX,20);
      image(hp,30,20);
      //score
      textSize(30);
      fill(0);
      text("score:"+count,10,440);
      //shoot
      for(int i=0;i<5;i++)
      {
        image(shoot,sx[i],sy[i]);
        closestEnemy=closestEnemy(sx[i],sy[i]);
        if(closestEnemy!=-1)
        {
            if(enemyY[i]>sy[i])
              sy[i]+=1;
            if(enemyY[i]<sy[i])
              sy[i]-=1;
        }else
        {
          sy[i]+=0;
        }
        sx[i]-=sSpeed;
        if(sx[i] < -31)
           sx[i] =sy[i]=-960;
      }
      //enemyhit
      for(int i=0;i<8;i++)
      {
        //enemy destory
        for(int j= 0;j< 5;j++)
        {
            bulletHit=isHit(enemyX[i],enemyY[i],61,61,sx[j],sy[j],31,27);
            if(bulletHit)
            {
                  sx[j] = sy[j] = -960;
                  fx[i] = enemyX[i];
                  fy[i] = enemyY[i];
                  flamesAppear[i] = true;
                  enemyDestory[i] = true;
                  enemyX[i] = enemyY[i] = -1;
                  scoreChange(20);
            }
        }
        //enemy hit
        enemyHit=isHit(enemyX[i],enemyY[i],61,61,ftx,fty,51,51);
        if(enemyHit)
        {
               fx[i] = enemyX[i];
               fy[i] = enemyY[i];
               flamesAppear[i] = true;
               enemyDestory[i] = true;
               enemyX[i] =enemyY[i] =-1;
               hpX-=Hp/5;
        }  
        //flames appear
        if(flamesAppear[i] == true)
        {
           image(flames[currentFrame[i]],fx[i],fy[i]);  
           if(frameCount % (60/10) == 0)
           {
             currentFrame[i]++;
             if(currentFrame[i] == 5)
             {
               flamesAppear[i] = false;
               currentFrame[i] = 0;
             }
           }
        }
      }
      //enemymove
      switch(EnemyState)
      {
        case ENEMY_RUN1:
          enemymove();
          enemyMoveOut(enemyX);
          if(enemyX[0]==-1&&enemyX[1]==-1&&enemyX[2]==-1&&enemyX[3]==-1&&enemyX[4]==-1&&enemyX[5]==-1&&enemyX[6]==-1&&enemyX[7]==-1)
          {
            EnemyState=ENEMY_RUN2;
            addEnemy(1);
          }
          break;
        case ENEMY_RUN2:  
          enemymove();
          enemyMoveOut(enemyX);
          if(enemyX[0]==-1&&enemyX[1]==-1&&enemyX[2]==-1&&enemyX[3]==-1&&enemyX[4]==-1&&enemyX[5]==-1&&enemyX[6]==-1&&enemyX[7]==-1)
          {
            EnemyState=ENEMY_RUN3;
            addEnemy(2);
          }
          break;
        case ENEMY_RUN3:
          enemymove();
          enemyMoveOut(enemyX);
          if(enemyX[0]==-1&&enemyX[1]==-1&&enemyX[2]==-1&&enemyX[3]==-1&&enemyX[4]==-1&&enemyX[5]==-1&&enemyX[6]==-1&&enemyX[7]==-1)
          {
            EnemyState=ENEMY_RUN1;
            addEnemy(0);
          }
          break;
      }
      //--------------------break-switch-------------------
      break;
    }
    //------------------------------------------------------
    case GAME_OVER:
    {
      image(end2,0,0);
      if(mouseX>209&&mouseX<433)
      {
        if(mouseY>310&&mouseY<347)
        {
          image(end1,0,0);
          if(mousePressed)
          {
            //hp
            hpX=Hp/5;
            //fighter
            ftx=width-61;
            fty=height/2;
            //treasure
            tx=random(41,601);
            ty=random(41,441);
            //state
            GameState=0;
            EnemyState=ENEMY_RUN1;
            //
            for(int i=0;i<8;i++)
            {
              enemyDestory[i]=false;
              flamesAppear[i] = false;
              currentFrame[i] = 0;
            }
            for(int i=0;i<5;i++)
            {
              sx[i]=-960;
              sy[i]=-960;
            }
          }
        }
      }
    }
    
    
    
  }
}

// 0 - straight, 1-slope, 2-dimond
void addEnemy(int type)
{  
  for (int i = 0; i < enemyCount; ++i) {
    enemyX[i] = -1;
    enemyY[i] = -1;
  }
  switch (type) {
    case 0:
      addStraightEnemy();
      break;
    case 1:
      addSlopeEnemy();
      break;
    case 2:
      addDiamondEnemy();
      break;
  }
}

void addStraightEnemy()
{
  float t = random(height - enemy.height);
  int h = int(t);
  for (int i = 0; i < 5; ++i) {

    enemyX[i] = (i+1)*-80;
    enemyY[i] = h;
  }
}
void addSlopeEnemy()
{
  float t = random(height - enemy.height * 5);
  int h = int(t);
  for (int i = 0; i < 5; ++i) {

    enemyX[i] = (i+1)*-80;
    enemyY[i] = h + i * 40;
  }
}
void addDiamondEnemy()
{
  float t = random( enemy.height * 3 ,height - enemy.height * 3);
  int h = int(t);
  int x_axis = 1;
  for (int i = 0; i < 8; ++i) {
    if (i == 0 || i == 7) {
      enemyX[i] = x_axis*-80;
      enemyY[i] = h;
      x_axis++;
    }
    else if (i == 1 || i == 5){
      enemyX[i] = x_axis*-80;
      enemyY[i] = h + 1 * 40;
      enemyX[i+1] = x_axis*-80;
      enemyY[i+1] = h - 1 * 40;
      i++;
      x_axis++;
      
    }
    else {
      enemyX[i] = x_axis*-80;
      enemyY[i] = h + 2 * 40;
      enemyX[i+1] = x_axis*-80;
      enemyY[i+1] = h - 2 * 40;
      i++;
      x_axis++;
    }
  }
}

void keyPressed()
{
  if(key==CODED)
  {
    switch(keyCode)
    {
      case UP:
        up=true;
        break;
      case DOWN:
        down=true;
        break;
      case RIGHT:
        right=true;
        break;
      case LEFT:
        left=true;
         break;
    }
  }
  if(key == ' '){
    for(int i= 0;i<5;i++){
      if(sy[i] == -960){
        sx[i] = ftx+fighter.width/5;
        sy[i] = fty+fighter.height/4;
        break;
      }
    }
  }
}
void keyReleased()
{
  if(key==CODED)
  {
    switch(keyCode)
    {
      case UP:
        up=false;
        break;
      case DOWN:
        down=false;
        break;
      case RIGHT:
        right=false;
        break;
      case LEFT:
        left=false;
         break;
    }
  }
}
void enemymove()
{
    for (int i = 0; i < enemyCount; ++i)
    {
      if (enemyX[i] != -1 || enemyY[i] != -1) 
      {
        image(enemy, enemyX[i], enemyY[i]);
        enemyX[i]+=5;
      }
    }
}
boolean isHit(float ax,float ay,float aw,float ah,float bx,float by,float bw,float bh)
{
  if(by<(ay+ah)&&ay<(by+bh)&&bx<(ax+aw)&&ax<(bx+bw))
    return true;
  else
   return false;
}
boolean isHit(int ax,int ay,int aw,int ah,int bx,int by,int bw,int bh)
{
  if(by<(ay+ah)&&ay<(by+bh)&&bx<(ax+aw)&&ax<(bx+bw))
    return true;
  else
   return false;
}
void enemyMoveOut(int[] enemy)
{
  for(int i=0;i<8;i++)
 {
    if(enemy[i]>width)
    {
      enemy[i]=-1;
      enemyY[i]=-1;
    }
  }
}
void scoreChange(int value)
{
  count+=value;
}
int closestEnemy(float x,float y)
{ 
  float[] distance=new float [8];
  int min=0;
  if((enemyX[0]>width&&enemyX[0]<0)&&(enemyX[1]>width&&enemyX[1]<0)&&(enemyX[2]>width&&enemyX[2]<0)&&(enemyX[3]>width&&enemyX[3]<0)&&
  (enemyX[4]>width&&enemyX[4]<0)&&(enemyX[5]>width&&enemyX[5]<0)&&(enemyX[6]>width&&enemyX[6]<0)&&(enemyX[7]>width&&enemyX[7]<0))
    return -1;
  for(int i=0;i<8;i++)
  {
    distance[i]=dist(x,y,enemyX[i],enemyY[i]);
  }
  for(int j=1;j<8;j++)
  {
    if(distance[j]<distance[min])
      min=j;
  }
  return min;
}
