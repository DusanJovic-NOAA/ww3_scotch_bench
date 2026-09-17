program ww3_scotch_part

   use mpi_f08

   implicit none

   interface
      subroutine SCOTCHFParMETIS_V3_PartGeomKway(vtxdist, xadj, adjncy, &
           vwgt, adjwgt, wgtflag, numflag, ndims, xyz, ncon, nparts, &
           tpwgts, ubvec, options, edgecut, part, comm, ref)
        import                     :: MPI_Comm
        integer, intent(in)        :: vtxdist(*), xadj(*), adjncy(*)
        integer, intent(in)        :: vwgt(*), adjwgt(*)
        integer, intent(in)        :: wgtflag, numflag, ndims, ncon, nparts
        real(4), intent(in)        :: xyz(*)
        real(4), intent(in)        :: tpwgts(*), ubvec(*)
        integer, intent(in)        :: options(*)
        integer, intent(out)       :: edgecut
        integer, intent(inout)     :: part(*)
        type(MPI_Comm), intent(in) :: comm
        integer, intent(out)       :: ref
      end subroutine SCOTCHFParMETIS_V3_PartGeomKway
   end interface

   type(MPI_COMM) :: comm
   integer :: nproc, myrank, ierr
   integer :: wgtflag, numflag, ndims, nparts, edgecut, ncon
   integer, allocatable :: xadj(:), part(:), vwgt(:), adjwgt(:), vtxdist(:), options(:), adjncy(:)
   real(4), allocatable :: xyz(:), tpwgts(:), ubvec(:)
   integer, allocatable :: part_orig(:)
   integer :: ref
   integer :: nTasks,np,ns
   integer :: stat, i, iostat
   character(len=64) :: mp_file_name
   integer :: mp_unit
   double precision :: start_time, end_time

   call MPI_Init(ierr)
   call MPI_Comm_size(MPI_COMM_WORLD, nproc, ierr)
   call MPI_Comm_rank(MPI_COMM_WORLD, myrank, ierr)

   call MPI_Comm_dup(MPI_COMM_WORLD, comm, ierr)

   ! only two number of tasks supported 60 from cpld_control_gfsv17 and 2008 from cpld_control_c1152_v17
   if (.not. (nproc==60 .or. nproc == 2008)) then
      write(0,*)'Unsupported nproc', nproc
      call exit(1)
   end if

   write(mp_file_name,'(A,I6.6,A,I6.6,A)') 'ww3_scotch_mesh_input/ww3_scotch_mesh_input_',nproc,'_',myrank,'.dat'
   open(newunit=mp_unit,file=trim(mp_file_name),status='old',action='read',form='unformatted',iostat=iostat)
   if (iostat/= 0) then
      write(0,*)'error opening ', trim(mp_file_name)
      call exit(1) ! FIXME handle io error properly
   endif
   read(mp_unit) nTasks,np,ns,ncon

   allocate(vtxdist(nTasks+1),stat=stat)
   allocate(xadj(np+1), stat=stat)
   allocate(adjncy(ns), stat=stat)
   allocate(vwgt(np*ncon), stat=stat)
   allocate(adjwgt(ns), stat=stat)
   allocate(xyz(2*np),stat=stat)
   allocate(tpwgts(ncon*nTasks),stat=stat)
   allocate(ubvec(ncon),stat=stat)
   allocate(options(3))
   allocate(part(np),stat=stat)
   allocate(part_orig(np),stat=stat)

   read(mp_unit) vtxdist
   read(mp_unit) xadj
   read(mp_unit) adjncy
   read(mp_unit) vwgt
   read(mp_unit) adjwgt
   read(mp_unit) wgtflag
   read(mp_unit) numflag
   read(mp_unit) ndims
   read(mp_unit) xyz
   read(mp_unit) ncon
   read(mp_unit) nparts
   read(mp_unit) tpwgts
   read(mp_unit) ubvec
   read(mp_unit) options
   read(mp_unit) edgecut
   read(mp_unit) part
   read(mp_unit) ref
   close(mp_unit)

   start_time = MPI_Wtime()

   call SCOTCHFParMETIS_V3_PartGeomKway(vtxdist, xadj, adjncy, &
                                        vwgt, &
                                        adjwgt, &
                                        wgtflag, &
                                        numflag,ndims,xyz,ncon, &
                                        nparts,tpwgts,ubvec,options, &
                                        edgecut, part, comm, ref)

   end_time = MPI_Wtime()
   if (myrank == 0) write(*,*) nproc, ' finished in ', end_time - start_time, ' seconds'

   if (myrank == 0) write(*,*) 'edgecut ' , edgecut
   if (myrank == 0) write(*,*) 'part(1:10) ', part(1:10)
   if (myrank == 0) write(*,*) 'ref =', ref, ' METIS_OK is 1'

   call MPI_Finalize(ierr)

end program ww3_scotch_part
