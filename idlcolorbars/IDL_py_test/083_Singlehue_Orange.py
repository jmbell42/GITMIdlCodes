from matplotlib.colors import LinearSegmentedColormap
from numpy import nan, inf
cm_data = [[0.0000208612, 0.0000200049, 0.0000198463],
[0.000395638, 0.000338433, 0.000302323],
[0.0011603, 0.000962008, 0.000833348],
[0.00228356, 0.00185165, 0.00156836],
[0.0037525, 0.00298694, 0.00248214],
[0.00556046, 0.0043544, 0.00355709],
[0.00770389, 0.0059442, 0.00477979],
[0.0101811, 0.00774877, 0.00613939],
[0.0129916, 0.00976203, 0.00762684],
[0.0161358, 0.011979, 0.00923438],
[0.0196146, 0.0143954, 0.0109552],
[0.0234295, 0.0170078, 0.0127834],
[0.0275823, 0.0198131, 0.0147134],
[0.032075, 0.0228085, 0.0167405],
[0.0369101, 0.0259918, 0.0188601],
[0.0420439, 0.029361, 0.0210681],
[0.0471638, 0.0329141, 0.0233607],
[0.0522409, 0.0366497, 0.0257344],
[0.0572795, 0.0405642, 0.0281858],
[0.0622833, 0.0444724, 0.0307119],
[0.0672554, 0.048334, 0.0333096],
[0.0721988, 0.0521521, 0.0359762],
[0.0771161, 0.0559296, 0.0387091],
[0.0820096, 0.0596689, 0.0414802],
[0.0868813, 0.0633724, 0.0441946],
[0.0917332, 0.0670421, 0.0468619],
[0.0965669, 0.0706801, 0.0494841],
[0.101384, 0.0742879, 0.0520631],
[0.106186, 0.0778672, 0.0546007],
[0.110974, 0.0814195, 0.0570984],
[0.11575, 0.0849462, 0.0595578],
[0.120514, 0.0884484, 0.0619802],
[0.125268, 0.0919274, 0.0643669],
[0.130013, 0.0953842, 0.0667192],
[0.134749, 0.0988199, 0.069038],
[0.139477, 0.102235, 0.0713244],
[0.144198, 0.105631, 0.0735794],
[0.148914, 0.109009, 0.0758039],
[0.153624, 0.112369, 0.0779987],
[0.158329, 0.115712, 0.0801647],
[0.16303, 0.119039, 0.0823025],
[0.167728, 0.12235, 0.084413],
[0.172423, 0.125646, 0.0864966],
[0.177115, 0.128928, 0.0885542],
[0.181806, 0.132195, 0.0905862],
[0.186495, 0.13545, 0.0925932],
[0.191183, 0.138691, 0.0945758],
[0.195871, 0.141921, 0.0965345],
[0.200559, 0.145138, 0.0984697],
[0.205247, 0.148344, 0.100382],
[0.209936, 0.151539, 0.102272],
[0.214626, 0.154723, 0.104139],
[0.219317, 0.157897, 0.105985],
[0.224011, 0.161062, 0.107809],
[0.228706, 0.164216, 0.109613],
[0.233404, 0.167362, 0.111395],
[0.238105, 0.170498, 0.113158],
[0.242809, 0.173626, 0.1149],
[0.247516, 0.176746, 0.116622],
[0.252227, 0.179857, 0.118325],
[0.256942, 0.182962, 0.120009],
[0.261661, 0.186058, 0.121674],
[0.266385, 0.189148, 0.12332],
[0.271113, 0.19223, 0.124947],
[0.275847, 0.195306, 0.126557],
[0.280585, 0.198375, 0.128148],
[0.285329, 0.201438, 0.129722],
[0.290079, 0.204495, 0.131277],
[0.294834, 0.207547, 0.132816],
[0.299596, 0.210593, 0.134337],
[0.304364, 0.213633, 0.135841],
[0.309138, 0.216668, 0.137328],
[0.313919, 0.219698, 0.138799],
[0.318707, 0.222724, 0.140252],
[0.323502, 0.225744, 0.14169],
[0.328305, 0.228761, 0.143111],
[0.333114, 0.231772, 0.144515],
[0.337932, 0.23478, 0.145904],
[0.342757, 0.237784, 0.147277],
[0.347591, 0.240784, 0.148634],
[0.352432, 0.24378, 0.149975],
[0.357282, 0.246773, 0.1513],
[0.36214, 0.249762, 0.15261],
[0.367007, 0.252748, 0.153905],
[0.371883, 0.255731, 0.155184],
[0.376768, 0.258711, 0.156448],
[0.381662, 0.261689, 0.157697],
[0.386565, 0.264663, 0.158931],
[0.391478, 0.267635, 0.160149],
[0.396401, 0.270605, 0.161353],
[0.401333, 0.273572, 0.162542],
[0.406275, 0.276536, 0.163716],
[0.411227, 0.279499, 0.164875],
[0.416189, 0.28246, 0.16602],
[0.421162, 0.285419, 0.167149],
[0.426145, 0.288376, 0.168265],
[0.431139, 0.291331, 0.169365],
[0.436144, 0.294285, 0.170451],
[0.441159, 0.297238, 0.171523],
[0.446186, 0.300189, 0.17258],
[0.451224, 0.303139, 0.173623],
[0.456273, 0.306087, 0.174651],
[0.461333, 0.309035, 0.175665],
[0.466406, 0.311982, 0.176664],
[0.471489, 0.314927, 0.177649],
[0.476585, 0.317872, 0.17862],
[0.481693, 0.320817, 0.179576],
[0.486813, 0.32376, 0.180518],
[0.491945, 0.326704, 0.181446],
[0.497089, 0.329646, 0.182359],
[0.502246, 0.332589, 0.183258],
[0.507416, 0.335531, 0.184143],
[0.512598, 0.338473, 0.185014],
[0.517794, 0.341415, 0.18587],
[0.523002, 0.344357, 0.186711],
[0.528223, 0.347299, 0.187539],
[0.533458, 0.350241, 0.188352],
[0.538706, 0.353183, 0.18915],
[0.543968, 0.356126, 0.189934],
[0.549243, 0.359069, 0.190704],
[0.554533, 0.362013, 0.191459],
[0.559836, 0.364957, 0.1922],
[0.565153, 0.367902, 0.192926],
[0.570484, 0.370847, 0.193637],
[0.575829, 0.373794, 0.194334],
[0.581189, 0.376741, 0.195017],
[0.586564, 0.379689, 0.195684],
[0.591953, 0.382638, 0.196337],
[0.596158, 0.386231, 0.199538],
[0.599164, 0.390471, 0.205295],
[0.602164, 0.394715, 0.211046],
[0.605158, 0.398965, 0.216794],
[0.608148, 0.403219, 0.222538],
[0.611132, 0.407478, 0.228281],
[0.614111, 0.411743, 0.234024],
[0.617085, 0.416012, 0.239767],
[0.620056, 0.420287, 0.24551],
[0.623022, 0.424567, 0.251256],
[0.625984, 0.428852, 0.257004],
[0.628943, 0.433143, 0.262755],
[0.631898, 0.43744, 0.26851],
[0.63485, 0.441742, 0.27427],
[0.637799, 0.44605, 0.280034],
[0.640745, 0.450364, 0.285803],
[0.643689, 0.454684, 0.291577],
[0.646631, 0.45901, 0.297358],
[0.649571, 0.463342, 0.303145],
[0.652509, 0.467681, 0.308938],
[0.655445, 0.472025, 0.314738],
[0.65838, 0.476377, 0.320546],
[0.661314, 0.480734, 0.326361],
[0.664247, 0.485099, 0.332184],
[0.66718, 0.48947, 0.338014],
[0.670112, 0.493848, 0.343853],
[0.673044, 0.498232, 0.3497],
[0.675976, 0.502624, 0.355555],
[0.678908, 0.507023, 0.361419],
[0.681841, 0.511429, 0.367292],
[0.684774, 0.515842, 0.373174],
[0.687709, 0.520263, 0.379065],
[0.690645, 0.524691, 0.384965],
[0.693582, 0.529126, 0.390874],
[0.696521, 0.53357, 0.396793],
[0.699461, 0.538021, 0.402721],
[0.702404, 0.542479, 0.408658],
[0.705349, 0.546946, 0.414606],
[0.708297, 0.551421, 0.420563],
[0.711247, 0.555904, 0.42653],
[0.714201, 0.560395, 0.432506],
[0.717158, 0.564894, 0.438493],
[0.720118, 0.569402, 0.44449],
[0.723082, 0.573918, 0.450497],
[0.72605, 0.578443, 0.456513],
[0.729022, 0.582976, 0.462541],
[0.731998, 0.587519, 0.468578],
[0.734979, 0.59207, 0.474625],
[0.737965, 0.59663, 0.480683],
[0.740956, 0.601199, 0.486751],
[0.743952, 0.605778, 0.49283],
[0.746954, 0.610365, 0.498919],
[0.749961, 0.614962, 0.505018],
[0.752975, 0.619569, 0.511128],
[0.755994, 0.624185, 0.517249],
[0.759021, 0.628811, 0.52338],
[0.762054, 0.633446, 0.529521],
[0.765093, 0.638092, 0.535673],
[0.76814, 0.642747, 0.541836],
[0.771195, 0.647413, 0.548009],
[0.774257, 0.652089, 0.554193],
[0.777327, 0.656775, 0.560387],
[0.780405, 0.661471, 0.566593],
[0.783491, 0.666178, 0.572809],
[0.786586, 0.670896, 0.579035],
[0.78969, 0.675624, 0.585272],
[0.792803, 0.680363, 0.59152],
[0.795925, 0.685113, 0.597779],
[0.799057, 0.689874, 0.604049],
[0.802199, 0.694646, 0.610329],
[0.80535, 0.69943, 0.61662],
[0.808513, 0.704224, 0.622922],
[0.811685, 0.709031, 0.629234],
[0.814869, 0.713848, 0.635558],
[0.818063, 0.718678, 0.641892],
[0.821269, 0.723519, 0.648237],
[0.824487, 0.728372, 0.654592],
[0.827717, 0.733238, 0.660959],
[0.830958, 0.738115, 0.667336],
[0.834212, 0.743004, 0.673724],
[0.837479, 0.747906, 0.680122],
[0.840759, 0.752821, 0.686532],
[0.844052, 0.757748, 0.692952],
[0.847358, 0.762687, 0.699383],
[0.850679, 0.76764, 0.705825],
[0.854013, 0.772605, 0.712277],
[0.857362, 0.777583, 0.71874],
[0.860726, 0.782575, 0.725213],
[0.864104, 0.787579, 0.731697],
[0.867498, 0.792597, 0.738192],
[0.870908, 0.797629, 0.744697],
[0.874333, 0.802674, 0.751213],
[0.877775, 0.807733, 0.757739],
[0.881233, 0.812805, 0.764275],
[0.884708, 0.817892, 0.770822],
[0.8882, 0.822992, 0.777379],
[0.89171, 0.828107, 0.783946],
[0.895238, 0.833236, 0.790523],
[0.898785, 0.838379, 0.797111],
[0.90235, 0.843536, 0.803708],
[0.905934, 0.848709, 0.810314],
[0.909537, 0.853896, 0.816931],
[0.913161, 0.859097, 0.823556],
[0.916805, 0.864314, 0.830192],
[0.92047, 0.869545, 0.836836],
[0.924156, 0.874792, 0.843489],
[0.927864, 0.880053, 0.850151],
[0.931594, 0.88533, 0.856821],
[0.935347, 0.890623, 0.863499],
[0.939123, 0.89593, 0.870185],
[0.942923, 0.901253, 0.876878],
[0.946748, 0.906592, 0.883578],
[0.950599, 0.911946, 0.890285],
[0.954475, 0.917315, 0.896997],
[0.958379, 0.9227, 0.903715],
[0.962311, 0.928101, 0.910437],
[0.966271, 0.933517, 0.917163],
[0.970262, 0.938949, 0.92389],
[0.974284, 0.944396, 0.930619],
[0.978339, 0.949859, 0.937347],
[0.982429, 0.955336, 0.944073],
[0.986557, 0.960828, 0.950793],
[0.990725, 0.966333, 0.957504],
[0.994938, 0.971852, 0.964202],
[0.999201, 0.977383, 0.970878],
[1., 0.982924, 0.977521],
[1., 0.98847, 0.984105],
[1., 0.994001, 0.990529]]

test_cm = LinearSegmentedColormap.from_list(__file__, cm_data)


if __name__ == "__main__":
    import matplotlib.pyplot as plt
    import numpy as np

    try:
        from pycam02ucs.cm.viscm import viscm
        viscm(test_cm)
    except ImportError:
        print("pycam02ucs not found, falling back on simple display")
        plt.imshow(np.linspace(0, 100, 256)[None, :], aspect='auto',
                   cmap=test_cm)
    plt.show()