from matplotlib.colors import LinearSegmentedColormap
from numpy import nan, inf
cm_data = [[0.0000208612, 0.0000200049, 0.0000198463],
[0.000376017, 0.000336718, 0.000392113],
[0.00109122, 0.000954445, 0.00116389],
[0.00213515, 0.00183203, 0.00231046],
[0.00349589, 0.00294686, 0.00382372],
[0.00516876, 0.00428312, 0.00570075],
[0.00715296, 0.00582857, 0.00794096],
[0.00945016, 0.00757309, 0.0105449],
[0.0120638, 0.00950799, 0.0135138],
[0.0149986, 0.0116256, 0.016849],
[0.0182605, 0.0139189, 0.0205521],
[0.021856, 0.0163815, 0.0246243],
[0.0257926, 0.0190074, 0.0290668],
[0.0300783, 0.0217911, 0.0338807],
[0.0347218, 0.0247272, 0.0390663],
[0.0397321, 0.0278106, 0.0444367],
[0.0448947, 0.0310364, 0.0497425],
[0.050034, 0.0344, 0.0549961],
[0.0551632, 0.0378969, 0.0602],
[0.060286, 0.0414966, 0.0653561],
[0.0654059, 0.0450369, 0.070466],
[0.0705261, 0.0485159, 0.0755306],
[0.075649, 0.0519363, 0.080551],
[0.0807771, 0.0553007, 0.0855275],
[0.0859123, 0.0586114, 0.0904607],
[0.0910565, 0.0618704, 0.0953505],
[0.0962111, 0.0650798, 0.100197],
[0.101378, 0.0682414, 0.105],
[0.106557, 0.0713568, 0.109759],
[0.111751, 0.0744277, 0.114474],
[0.116959, 0.0774556, 0.119145],
[0.122184, 0.080442, 0.12377],
[0.127424, 0.0833881, 0.128349],
[0.132682, 0.0862954, 0.132882],
[0.137956, 0.0891651, 0.137367],
[0.143249, 0.0919985, 0.141804],
[0.148559, 0.0947969, 0.146191],
[0.153886, 0.0975613, 0.150529],
[0.159232, 0.100293, 0.154816],
[0.164596, 0.102993, 0.159051],
[0.169978, 0.105663, 0.163233],
[0.175377, 0.108303, 0.167362],
[0.180794, 0.110915, 0.171435],
[0.186228, 0.113501, 0.175453],
[0.19168, 0.11606, 0.179414],
[0.197148, 0.118594, 0.183318],
[0.202632, 0.121105, 0.187163],
[0.208132, 0.123593, 0.190949],
[0.213647, 0.12606, 0.194674],
[0.219177, 0.128506, 0.198338],
[0.224722, 0.130933, 0.201939],
[0.23028, 0.133342, 0.205478],
[0.235851, 0.135734, 0.208953],
[0.241435, 0.138111, 0.212363],
[0.24703, 0.140472, 0.215708],
[0.252637, 0.14282, 0.218987],
[0.258253, 0.145156, 0.2222],
[0.26388, 0.147481, 0.225345],
[0.269515, 0.149796, 0.228422],
[0.275158, 0.152102, 0.231432],
[0.280809, 0.1544, 0.234372],
[0.286466, 0.156692, 0.237243],
[0.292128, 0.158979, 0.240045],
[0.297796, 0.161262, 0.242777],
[0.303467, 0.163542, 0.245439],
[0.309141, 0.16582, 0.24803],
[0.314818, 0.168099, 0.250552],
[0.320495, 0.170377, 0.253003],
[0.326173, 0.172658, 0.255383],
[0.33185, 0.174943, 0.257693],
[0.337526, 0.177231, 0.259933],
[0.343199, 0.179526, 0.262103],
[0.348869, 0.181827, 0.264203],
[0.354535, 0.184136, 0.266233],
[0.360195, 0.186455, 0.268195],
[0.365849, 0.188783, 0.270087],
[0.371496, 0.191124, 0.271912],
[0.377135, 0.193477, 0.273669],
[0.382765, 0.195844, 0.275359],
[0.388384, 0.198226, 0.276982],
[0.393993, 0.200625, 0.27854],
[0.399589, 0.20304, 0.280034],
[0.405173, 0.205475, 0.281464],
[0.410743, 0.207928, 0.28283],
[0.416298, 0.210402, 0.284136],
[0.421837, 0.212898, 0.28538],
[0.427359, 0.215416, 0.286565],
[0.432864, 0.217958, 0.287691],
[0.43835, 0.220525, 0.28876],
[0.443816, 0.223117, 0.289773],
[0.449262, 0.225736, 0.290732],
[0.454686, 0.228382, 0.291638],
[0.460088, 0.231057, 0.292492],
[0.465467, 0.233761, 0.293297],
[0.470821, 0.236496, 0.294053],
[0.47615, 0.239261, 0.294762],
[0.481453, 0.242058, 0.295426],
[0.486729, 0.244888, 0.296047],
[0.491977, 0.247751, 0.296626],
[0.497197, 0.250649, 0.297166],
[0.502386, 0.253581, 0.297668],
[0.507545, 0.256548, 0.298134],
[0.512673, 0.259552, 0.298566],
[0.517768, 0.262593, 0.298966],
[0.522831, 0.26567, 0.299337],
[0.527859, 0.268786, 0.29968],
[0.532853, 0.27194, 0.299998],
[0.53781, 0.275133, 0.300292],
[0.542732, 0.278366, 0.300566],
[0.547616, 0.281638, 0.30082],
[0.552462, 0.28495, 0.301059],
[0.55727, 0.288303, 0.301283],
[0.562038, 0.291697, 0.301495],
[0.566766, 0.295132, 0.301699],
[0.571452, 0.298609, 0.301895],
[0.576097, 0.302127, 0.302087],
[0.5807, 0.305687, 0.302277],
[0.585259, 0.30929, 0.302468],
[0.589775, 0.312935, 0.302662],
[0.594246, 0.316622, 0.302863],
[0.598672, 0.320351, 0.303071],
[0.603052, 0.324123, 0.303291],
[0.607385, 0.327938, 0.303525],
[0.611672, 0.331796, 0.303775],
[0.615911, 0.335695, 0.304045],
[0.620103, 0.339638, 0.304336],
[0.624245, 0.343622, 0.304653],
[0.628338, 0.347649, 0.304997],
[0.632382, 0.351719, 0.305371],
[0.636376, 0.35583, 0.305779],
[0.640319, 0.359982, 0.306222],
[0.644211, 0.364176, 0.306705],
[0.648051, 0.368412, 0.307229],
[0.65184, 0.372688, 0.307798],
[0.655577, 0.377005, 0.308414],
[0.659261, 0.381362, 0.30908],
[0.662893, 0.385759, 0.309799],
[0.666472, 0.390196, 0.310574],
[0.669997, 0.394671, 0.311408],
[0.673469, 0.399186, 0.312303],
[0.676887, 0.403738, 0.313263],
[0.680252, 0.408328, 0.31429],
[0.683563, 0.412955, 0.315386],
[0.68682, 0.417618, 0.316555],
[0.690023, 0.422318, 0.3178],
[0.693172, 0.427053, 0.319122],
[0.696268, 0.431823, 0.320524],
[0.699309, 0.436627, 0.32201],
[0.702297, 0.441464, 0.32358],
[0.705232, 0.446334, 0.325239],
[0.708113, 0.451237, 0.326989],
[0.710941, 0.45617, 0.32883],
[0.713717, 0.461135, 0.330767],
[0.71644, 0.466129, 0.332801],
[0.719111, 0.471153, 0.334934],
[0.721732, 0.476205, 0.337168],
[0.724301, 0.481284, 0.339505],
[0.726819, 0.486391, 0.341947],
[0.729289, 0.491523, 0.344495],
[0.731709, 0.49668, 0.347152],
[0.73408, 0.501862, 0.349919],
[0.736405, 0.507066, 0.352797],
[0.738682, 0.512294, 0.355788],
[0.740914, 0.517542, 0.358893],
[0.743101, 0.522812, 0.362113],
[0.745244, 0.528101, 0.365448],
[0.747345, 0.533409, 0.368901],
[0.749404, 0.538735, 0.372471],
[0.751423, 0.544078, 0.37616],
[0.753403, 0.549436, 0.379967],
[0.755346, 0.55481, 0.383894],
[0.757253, 0.560198, 0.38794],
[0.759124, 0.565599, 0.392106],
[0.760963, 0.571012, 0.396392],
[0.762771, 0.576436, 0.400797],
[0.764549, 0.58187, 0.405322],
[0.766299, 0.587313, 0.409967],
[0.768023, 0.592765, 0.41473],
[0.769722, 0.598223, 0.419612],
[0.7714, 0.603688, 0.424612],
[0.773058, 0.609159, 0.429729],
[0.774697, 0.614633, 0.434962],
[0.776321, 0.620111, 0.44031],
[0.777932, 0.625591, 0.445772],
[0.779531, 0.631073, 0.451347],
[0.781121, 0.636556, 0.457035],
[0.782706, 0.642038, 0.462832],
[0.784286, 0.647518, 0.468739],
[0.785865, 0.652997, 0.474752],
[0.787445, 0.658472, 0.480872],
[0.789029, 0.663944, 0.487096],
[0.79062, 0.66941, 0.493422],
[0.79222, 0.674871, 0.499848],
[0.793832, 0.680326, 0.506372],
[0.795459, 0.685773, 0.512993],
[0.797104, 0.691213, 0.519708],
[0.798769, 0.696644, 0.526514],
[0.800458, 0.702065, 0.533411],
[0.802174, 0.707476, 0.540394],
[0.803919, 0.712876, 0.547463],
[0.805696, 0.718265, 0.554613],
[0.807508, 0.723642, 0.561844],
[0.809358, 0.729006, 0.569152],
[0.811249, 0.734357, 0.576535],
[0.813184, 0.739694, 0.583989],
[0.815166, 0.745017, 0.591513],
[0.817197, 0.750325, 0.599103],
[0.81928, 0.755619, 0.606756],
[0.821419, 0.760896, 0.61447],
[0.823615, 0.766158, 0.622242],
[0.825872, 0.771404, 0.630069],
[0.828191, 0.776633, 0.637948],
[0.830576, 0.781846, 0.645876],
[0.833029, 0.787042, 0.65385],
[0.835552, 0.792221, 0.661867],
[0.838148, 0.797383, 0.669924],
[0.840818, 0.802528, 0.678017],
[0.843565, 0.807655, 0.686145],
[0.846391, 0.812766, 0.694303],
[0.849297, 0.817859, 0.70249],
[0.852286, 0.822935, 0.710701],
[0.855359, 0.827994, 0.718933],
[0.858517, 0.833037, 0.727185],
[0.861762, 0.838063, 0.735452],
[0.865095, 0.843073, 0.743732],
[0.868518, 0.848067, 0.752021],
[0.872031, 0.853045, 0.760317],
[0.875635, 0.858009, 0.768617],
[0.879331, 0.862957, 0.776918],
[0.88312, 0.867891, 0.785217],
[0.887001, 0.872812, 0.793511],
[0.890976, 0.877719, 0.801797],
[0.895045, 0.882614, 0.810073],
[0.899207, 0.887497, 0.818336],
[0.903462, 0.892369, 0.826582],
[0.907811, 0.89723, 0.83481],
[0.912252, 0.902081, 0.843016],
[0.916786, 0.906924, 0.851198],
[0.921412, 0.911759, 0.859353],
[0.926128, 0.916586, 0.867478],
[0.930934, 0.921408, 0.875572],
[0.935829, 0.926224, 0.88363],
[0.940811, 0.931037, 0.891651],
[0.94588, 0.935847, 0.899631],
[0.951033, 0.940655, 0.907569],
[0.956268, 0.945463, 0.91546],
[0.961585, 0.950271, 0.923301],
[0.96698, 0.955083, 0.931089],
[0.972451, 0.959899, 0.938821],
[0.977995, 0.964721, 0.946491],
[0.98361, 0.969552, 0.954093],
[0.989289, 0.974394, 0.961621],
[0.995029, 0.979251, 0.969063],
[1., 0.984127, 0.976403],
[1., 0.989033, 0.983606],
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
