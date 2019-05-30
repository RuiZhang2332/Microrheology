num = 1213;
head = '/Users/rzhang/Desktop/tracking/';
first = 11;
last = 901;

I1 = importdata([head, num2str(num),'/', num2str(num),'_T', num2str(first,'%04u'),'.tif']);
I2 = importdata([head, num2str(num),'/', num2str(num),'_T', num2str(last,'%04u'),'.tif']);

I2i=65535-I2;  Ib2=bpass(I2i,5,49);
colormap('gray');imagesc(Ib2);
max(max(Ib2))
br = ans*0.4

Beadtrack_movie([head, num2str(num),'/', num2str(num),'_T'],'%04u',11,901,49,br,5,0,47,40)

first = 11;
last = 901;

Bposlist = Beadtrack([head, num2str(num),'/', num2str(num),'_T'],'%04u',first,last,49,br,5);

hist(mod(Bposlist(:,1),1),20);
title('bias check for x')
figure;
hist(mod(Bposlist(:,2),1),20);
title('bias check for y')

Bparam = struct('mem',0,'good',60,'dim',2,'quiet',1);
Bpos = Bposlist(:,[1:2,6]);
Btrack = track(Bpos,100,Bparam);

Btraj = [Btrack(:,1) Btrack(:,2)];
scatter(Btraj(:,1),Btraj(:,2),'.');
xlim([0 1376]);ylim([0 1376]);
print([head, num2str(num),' tracking/', num2str(num),' bead traj'],'-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I1 = flipud(I1); I2 = flipud(I2);
figure; colormap('gray');imagesc(I1);
set(gca,'YDir','normal');grid on;

Ib=bpass(I1,3,23);
figure; colormap('gray');imagesc(Ib);set(gca,'YDir','normal');grid on;

pk=pkfnd(Ib,3,23);
cnt=cntrd_RZ(Ib,pk,25);
figure;plot(cnt(:,3),cnt(:,4),'.');
yticks([10 20 30 32 35 40 50 60 70 80]);
xticks([500 1000 1500 2000 3000 5000 7000 8000 10000]);grid on;

checkLH(Ib,cnt,3,0,10000)

figure;histogram(cnt(:,5),300)

%   Mass cut:  R<30 R>55, I<1400  I>15000 e cut: 0.25
%   lnoise = 3  th=6
poslist=PMMAtrack3([head, num2str(num),'/', num2str(num),'_T'],'%04u',first,last,23,3,3,0.15,1,0.14,0.91,0.2,1,13,30);

param = struct('mem',0,'good',20,'dim',2,'quiet',1);
pos = poslist(:,[1:2,6]);
Ptrack = track(pos,10,param);

Ptrack1 = cutbead(Btrack,Ptrack,first,last,150);
load chirp
sound(y,Fs)

out=num_frame(poslist,1);
out=num_frame(Ptrack1,2);
plot(out(:,1),out(:,2))

%calculate drift
result=motion(Ptrack1,[1,0], 2);
result=[0 0 0 0;result];
n = length(result(:,1))
res = zeros(n,4);
for i2 = 2:n
res(i2,3) = res(i2-1,3)+result(i2,3);
res(i2,4) = res(i2-1,4)+result(i2,4);
end
temp = last - first
t = 0.125*[0:temp]'; xd = res(:,3); yd = res(:,4);

% Save 
save([head, num2str(num),' tracking/',num2str(num),' workspace.mat']);

xdrift = fittedmodelx(t);
ydrift = fittedmodely(t);
scatter(t,xd,'.r');
hold on;
scatter(t,yd,'.b');
plot(t,xdrift,'r',t,ydrift,'b','LineWidth',3);
legend({'X-drift','Y-drift'},'Fontsize',14);
title('X-drift & Y-drift','Fontsize',14);
print('D:\Microrheology\2019\0.3\P = 9.5\36 tracking\36 drift','-dpng');

x = Btraj(:,1)-xdrift; 
y = Btraj(:,2)-ydrift; 
x = x-x(1); y = y-y(1); 
xo = Btraj(:,1)-Btraj(1,1); yo = Btraj(:,2)-Btraj(1,2);
[v,x3,y3] = dedrift_velocityb(t,x,y,xo,yo,0.1);               % 1.9 - 1.8, the angle of the camera is 1.8
a1=[t x3 y3];

% Save 
print('D:\Microrheology\2019\0.3\P = 9.5\36 tracking\36 U','-dpng');
save('D:\Microrheology\2019\0.3\P = 9.5\36 tracking\36 workspace.mat');
path = 'D:\Microrheology\2019\0.3\P = 0';
filename = '0.3_9.5_36.txt';
file = [path filesep filename];
save(file,'a1','-ascii');