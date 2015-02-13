function get_robust_path_two(start_node, end_node, p, q, c, d, Gamma_u, Gamma_v, origin, destination)
  @assert length(start_node)==length(end_node)
  @assert length(start_node)==length(p)
  @assert length(start_node)==length(q)
  @assert length(start_node)==length(c)
  @assert length(start_node)==length(d)

  graph = create_graph(start_node, end_node)
  no_arc = num_edges(graph)

  # Step 0
  diag = p.*q + q.*c + q.*d
  idx = sortperm(diag, rev=true)
  Theta = Array((Float64, Float64),1)
  Theta = [(0,0)]

  for t=1:no_arc
    ij = idx[t]

    # Step 1
    Theta = [Theta; (0, p[ij]*d[ij]+q[ij]*d[ij])]


    # Step 2
    Ay  = p[ij]*d[ij] + q[ij]*d[ij]
    Bx  = q[ij]*c[ij]
    Cxy = p[ij]*d[ij] + q[ij]*c[ij] + q[ij]*d[ij]
    Dx  = q[ij]*c[ij] + q[ij]*d[ij]
    Ey  = p[ij]*d[ij]

    for s=t+1:no_arc
      kl = idx[s]

      AAy  = p[kl]*d[kl] + q[kl]*d[kl]
      BBx  = q[kl]*c[kl]
      CCxy = p[kl]*d[kl] + q[kl]*c[kl] + q[kl]*d[kl]
      DDx  = q[kl]*c[kl] + q[kl]*d[kl]
      EEy  = p[kl]*d[kl]

      # Pattern 1
      if Ay>AAy && Bx>BBx && Ey <EEy
        Theta = [Theta; (BBx, Ay); (Cxy-EEy, EEy)]
      end

      # Pattern 2
      if Ay>AAy && Bx>BBx && Ey>EEy && Dx>DDx
        Theta = [Theta; (BBx, Ay); (Dx, EEy)]
      end

      # Pattern 3
      if Ay>AAy && Bx>BBx && Dx<DDx && Ey>EEy
        Theta = [Theta; (BBx, Ay); (Dx, CCxy-Dx)]
      end

      # Pattern 4
      if EEy<Ay && Ay<AAy && Bx>BBx && Ey<EEy
        Theta = [Theta; (CCxy-Ay,Ay); (Cxy-EEy, EEy)]
      end

      # Pattern 5
      if EEy<Ay && Ay<AAy && Bx>BBx && Ey>EEy && Dx > DDx
        Theta = [Theta; (CCxy-Ay,Ay); (Dx, EEy)]
      end

      # Pattern 6
      if EEy<Ay && Ay<AAy && Bx>BBx && Ey>EEy && Dx < DDx
        Theta = [Theta; (CCxy-Ay,Ay); (Dx, CCxy-Dx)]
      end

      # Pattern 7
      if Bx>DDx && Ay<EEy
        Theta = [Theta; (DDx, Ay); (Bx, EEy)]
      end

      # Pattern 8
      if Bx<BBx && Ey<EEy
        Theta = [Theta; (BBx, Cxy-BBx); (Cxy-EEy, EEy)]
      end

      # Pattern 9
      if Bx<BBx && Ey>EEy && Dx>DDx
        Theta = [Theta; (BBx, Cxy-BBx); (Dx, EEy)]
      end

      # Pattern 10
      if Bx<BBx && Ey>EEy && Dx<DDx
        Theta = [Theta; (BBx, Cxy-BBx); (Dx, CCxy-Dx)]
      end

      # Pattern 11
      if Ey>AAy && Dx<BBx
        Theta = [Theta; (Dx, AAy); (BBx, Ey)]
      end
    end
  end
  # The set Theta contains all necessary (theta_u, theta_v)



  theta_u = zeros(size(Theta))
  theta_v = zeros(size(Theta))
  z_front = zeros(size(Theta))
  for i=1:length(Theta)
    theta_u[i] = Theta[i][1]
    theta_v[i] = Theta[i][2]
    z_front[i] = Gamma_u*theta_u[i] + Gamma_v*theta_v[i]
  end

  z_idx = sortperm(z_front, rev=true)

  best_obj = Inf
  best_path = []
  best_x = []

  for i=1:length(Theta)
    k = z_idx[i]
    if Gamma_u*theta_u[k] + Gamma_v*theta_v[k] >= best_obj
        break
    end

    rho_mu = zeros(no_arc)
    for ij=1:no_arc
        qc = q[ij]*c[ij]
        pd = p[ij]*d[ij]
        qd = q[ij]*d[ij]

        Condition1 = theta_u[k]>=qc && theta_v[k]>=pd+qd
        Condition2 = theta_u[k]<=qc && theta_v[k]>=pd+qd
        Condition3 = pd<=theta_v[k] && theta_v[k]<=pd+qd && theta_u[k]+theta_v[k]<=pd+qc+qd
        Condition4 = pd<=theta_v[k] && theta_v[k]<=pd+qd && theta_u[k]+theta_v[k]>=pd+qc+qd
        Condition5 = theta_u[k]<=qc+qd && theta_v[k]<=pd
        Condition6 = theta_u[k]>=qc+qd && theta_v[k]<=pd

        if Condition1 || Condition4
          rho_mu[ij] = 0
        elseif Condition2
          rho_mu[ij] = qc-theta_u[k]
        elseif Condition3 || Condition5
          rho_mu[ij] = pd+qc+qd-theta_u[k]-theta_v[k]
        elseif Condition6
          rho_mu[ij] = pd-theta_v[k]
        end
    end


    link_cost = p.*c + rho_mu
    (pp, xx) = get_shortest_path(start_node, end_node, link_cost, origin, destination)
    current_obj = Gamma_u*theta_u[k] + Gamma_v*theta_v[k] + dot(link_cost, xx)

    if current_obj < best_obj
        best_obj = current_obj
        best_path = pp
        best_x = xx
    end


  end

  return (best_path, best_x, best_obj)

end
