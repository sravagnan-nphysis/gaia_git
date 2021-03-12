function mu = CircularMean(alpha)
% alpha=[350 30]';
r = sum(exp(1i*deg2rad(alpha)),1);
mu = rad2deg(angle(r));
mu(mu<0)=360-abs(mu(mu<0));
end

