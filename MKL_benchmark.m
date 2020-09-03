for N=[10, 100, 1000, 2500, 5000, 7500, 10000]
    if N<100
        N_mult = 1000;
    elseif N<5001
        N_mult = 100;
    else
        N_mult = 10;
    end
    fprintf('N = %d: ', N);
 
    rng(1);
    A = rand(N);
    B = rand(N);
    A_pd = A*A';
 
    tic;
    svd(A);
    t_svd = toc;
    fprintf('SVD ');
 
    tic;
    chol(A_pd);
    t_chol = toc;
    fprintf('Chol ');
 
    tic;
    qr(A);
    t_qr = toc;
    fprintf('QR ');
 
    tic;
    for k=1:N_mult
        A*B;
    end
    t_mult = toc;
    fprintf('%d mult ', N_mult);
 
    tic;
    inv(A);
    t_inv = toc;
    fprintf('Inv ');
 
    tic;
    pinv(A);
    t_pinv = toc;
    fprintf('Pinv\n\n');
 
    fprintf('TIME IN SECONDS (SIZE: %d):\n', N);
    fprintf('SVD: %f\n', t_svd);
    fprintf('Cholesky: %f\n', t_chol);
    fprintf('QR: %f\n', t_qr);
    fprintf('%d matrix products: %f\n', N_mult, t_mult);
    fprintf('Inverse: %f\n', t_inv);
    fprintf('Pseudo-inverse: %f\n\n', t_pinv);
end