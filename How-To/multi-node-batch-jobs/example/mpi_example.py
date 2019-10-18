# From https://mpi4py.readthedocs.io/en/stable/tutorial.html
#

from mpi4py import MPI
import numpy

comm = MPI.COMM_WORLD
rank = comm.Get_rank()

print('Hello from rank', rank)

# Pass data from rank 0 to 1
if rank == 0:
    data = numpy.arange(100, dtype=numpy.float64)
    comm.Send(data, dest=1, tag=13)
elif rank == 1:
    data = numpy.empty(100, dtype=numpy.float64)
    comm.Recv(data, source=0, tag=13)

    result = numpy.arange(100, dtype=numpy.float64)
    print('Error: ', numpy.linalg.norm(data-result))
