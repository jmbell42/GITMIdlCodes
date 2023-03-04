from matplotlib.colors import LinearSegmentedColormap
from numpy import nan, inf
cm_data = [[1., 1., 0.898039],
[1., 1., 0.894118],
[1., 0.996078, 0.886275],
[1., 0.996078, 0.882353],
[1., 0.996078, 0.878431],
[1., 0.996078, 0.870588],
[1., 0.992157, 0.866667],
[1., 0.992157, 0.862745],
[1., 0.992157, 0.854902],
[1., 0.992157, 0.85098],
[1., 0.988235, 0.847059],
[1., 0.988235, 0.839216],
[1., 0.988235, 0.835294],
[1., 0.988235, 0.831373],
[1., 0.984314, 0.823529],
[1., 0.984314, 0.819608],
[1., 0.984314, 0.815686],
[1., 0.984314, 0.811765],
[1., 0.980392, 0.803922],
[1., 0.980392, 0.8],
[1., 0.980392, 0.796078],
[1., 0.980392, 0.788235],
[1., 0.976471, 0.784314],
[1., 0.976471, 0.780392],
[1., 0.976471, 0.772549],
[1., 0.976471, 0.768627],
[1., 0.972549, 0.764706],
[1., 0.972549, 0.756863],
[1., 0.972549, 0.752941],
[1., 0.972549, 0.74902],
[1., 0.968627, 0.741176],
[1., 0.968627, 0.737255],
[1., 0.964706, 0.733333],
[1., 0.964706, 0.72549],
[1., 0.960784, 0.721569],
[1., 0.960784, 0.717647],
[1., 0.956863, 0.709804],
[1., 0.952941, 0.705882],
[1., 0.952941, 0.701961],
[1., 0.94902, 0.694118],
[1., 0.945098, 0.690196],
[1., 0.945098, 0.686275],
[1., 0.941176, 0.678431],
[1., 0.941176, 0.67451],
[1., 0.937255, 0.670588],
[1., 0.933333, 0.662745],
[1., 0.933333, 0.658824],
[1., 0.929412, 0.654902],
[0.996078, 0.92549, 0.647059],
[0.996078, 0.92549, 0.643137],
[0.996078, 0.921569, 0.635294],
[0.996078, 0.921569, 0.631373],
[0.996078, 0.917647, 0.627451],
[0.996078, 0.913725, 0.619608],
[0.996078, 0.913725, 0.615686],
[0.996078, 0.909804, 0.611765],
[0.996078, 0.905882, 0.603922],
[0.996078, 0.905882, 0.6],
[0.996078, 0.901961, 0.596078],
[0.996078, 0.901961, 0.588235],
[0.996078, 0.898039, 0.584314],
[0.996078, 0.894118, 0.580392],
[0.996078, 0.894118, 0.572549],
[0.996078, 0.890196, 0.568627],
[0.996078, 0.886275, 0.560784],
[0.996078, 0.882353, 0.552941],
[0.996078, 0.878431, 0.545098],
[0.996078, 0.87451, 0.537255],
[0.996078, 0.870588, 0.529412],
[0.996078, 0.866667, 0.521569],
[0.996078, 0.862745, 0.513725],
[0.996078, 0.858824, 0.505882],
[0.996078, 0.854902, 0.494118],
[0.996078, 0.85098, 0.486275],
[0.996078, 0.847059, 0.478431],
[0.996078, 0.843137, 0.470588],
[0.996078, 0.839216, 0.462745],
[0.996078, 0.835294, 0.454902],
[0.996078, 0.831373, 0.447059],
[0.996078, 0.831373, 0.439216],
[0.996078, 0.827451, 0.431373],
[0.996078, 0.823529, 0.423529],
[0.996078, 0.819608, 0.415686],
[0.996078, 0.815686, 0.407843],
[0.996078, 0.811765, 0.4],
[0.996078, 0.807843, 0.392157],
[0.996078, 0.803922, 0.384314],
[0.996078, 0.8, 0.376471],
[0.996078, 0.796078, 0.364706],
[0.996078, 0.792157, 0.356863],
[0.996078, 0.788235, 0.34902],
[0.996078, 0.784314, 0.341176],
[0.996078, 0.780392, 0.333333],
[0.996078, 0.776471, 0.32549],
[0.996078, 0.772549, 0.317647],
[0.996078, 0.768627, 0.309804],
[0.996078, 0.764706, 0.305882],
[0.996078, 0.756863, 0.301961],
[0.996078, 0.752941, 0.294118],
[0.996078, 0.74902, 0.290196],
[0.996078, 0.741176, 0.286275],
[0.996078, 0.737255, 0.282353],
[0.996078, 0.733333, 0.278431],
[0.996078, 0.72549, 0.27451],
[0.996078, 0.721569, 0.266667],
[0.996078, 0.717647, 0.262745],
[0.996078, 0.709804, 0.258824],
[0.996078, 0.705882, 0.254902],
[0.996078, 0.701961, 0.25098],
[0.996078, 0.694118, 0.243137],
[0.996078, 0.690196, 0.239216],
[0.996078, 0.686275, 0.235294],
[0.996078, 0.678431, 0.231373],
[0.996078, 0.67451, 0.227451],
[0.996078, 0.666667, 0.219608],
[0.996078, 0.662745, 0.215686],
[0.996078, 0.658824, 0.211765],
[0.996078, 0.65098, 0.207843],
[0.996078, 0.647059, 0.203922],
[0.996078, 0.643137, 0.2],
[0.996078, 0.635294, 0.192157],
[0.996078, 0.631373, 0.188235],
[0.996078, 0.627451, 0.184314],
[0.996078, 0.619608, 0.180392],
[0.996078, 0.615686, 0.176471],
[0.996078, 0.611765, 0.168627],
[0.996078, 0.603922, 0.164706],
[0.996078, 0.6, 0.160784],
[0.992157, 0.596078, 0.156863],
[0.992157, 0.588235, 0.156863],
[0.988235, 0.584314, 0.152941],
[0.988235, 0.580392, 0.14902],
[0.984314, 0.576471, 0.14902],
[0.984314, 0.568627, 0.145098],
[0.980392, 0.564706, 0.141176],
[0.980392, 0.560784, 0.141176],
[0.976471, 0.552941, 0.137255],
[0.972549, 0.54902, 0.133333],
[0.972549, 0.545098, 0.133333],
[0.968627, 0.541176, 0.129412],
[0.968627, 0.533333, 0.12549],
[0.964706, 0.529412, 0.12549],
[0.964706, 0.52549, 0.121569],
[0.960784, 0.521569, 0.121569],
[0.956863, 0.513725, 0.117647],
[0.956863, 0.509804, 0.113725],
[0.952941, 0.505882, 0.113725],
[0.952941, 0.498039, 0.109804],
[0.94902, 0.494118, 0.105882],
[0.94902, 0.490196, 0.105882],
[0.945098, 0.486275, 0.101961],
[0.945098, 0.478431, 0.0980392],
[0.941176, 0.47451, 0.0980392],
[0.937255, 0.470588, 0.0941176],
[0.937255, 0.462745, 0.0901961],
[0.933333, 0.458824, 0.0901961],
[0.933333, 0.454902, 0.0862745],
[0.929412, 0.45098, 0.0823529],
[0.929412, 0.443137, 0.0823529],
[0.92549, 0.439216, 0.0784314],
[0.921569, 0.435294, 0.0745098],
[0.917647, 0.431373, 0.0745098],
[0.913725, 0.427451, 0.0705882],
[0.909804, 0.423529, 0.0705882],
[0.905882, 0.415686, 0.0666667],
[0.901961, 0.411765, 0.0666667],
[0.898039, 0.407843, 0.0627451],
[0.894118, 0.403922, 0.0627451],
[0.890196, 0.4, 0.0588235],
[0.886275, 0.396078, 0.054902],
[0.882353, 0.392157, 0.054902],
[0.878431, 0.388235, 0.0509804],
[0.87451, 0.380392, 0.0509804],
[0.870588, 0.376471, 0.0470588],
[0.866667, 0.372549, 0.0470588],
[0.862745, 0.368627, 0.0431373],
[0.858824, 0.364706, 0.0392157],
[0.854902, 0.360784, 0.0392157],
[0.85098, 0.356863, 0.0352941],
[0.847059, 0.352941, 0.0352941],
[0.843137, 0.345098, 0.0313725],
[0.839216, 0.341176, 0.0313725],
[0.835294, 0.337255, 0.027451],
[0.831373, 0.333333, 0.027451],
[0.827451, 0.329412, 0.0235294],
[0.823529, 0.32549, 0.0196078],
[0.819608, 0.321569, 0.0196078],
[0.815686, 0.317647, 0.0156863],
[0.811765, 0.309804, 0.0156863],
[0.807843, 0.305882, 0.0117647],
[0.803922, 0.301961, 0.0117647],
[0.8, 0.298039, 0.00784314],
[0.792157, 0.294118, 0.00784314],
[0.788235, 0.294118, 0.00784314],
[0.780392, 0.290196, 0.00784314],
[0.776471, 0.286275, 0.00784314],
[0.768627, 0.282353, 0.00784314],
[0.760784, 0.282353, 0.00784314],
[0.756863, 0.278431, 0.00784314],
[0.74902, 0.27451, 0.0117647],
[0.745098, 0.270588, 0.0117647],
[0.737255, 0.270588, 0.0117647],
[0.729412, 0.266667, 0.0117647],
[0.72549, 0.262745, 0.0117647],
[0.717647, 0.258824, 0.0117647],
[0.713725, 0.258824, 0.0117647],
[0.705882, 0.254902, 0.0117647],
[0.701961, 0.25098, 0.0117647],
[0.694118, 0.247059, 0.0117647],
[0.686275, 0.247059, 0.0117647],
[0.682353, 0.243137, 0.0117647],
[0.67451, 0.239216, 0.0117647],
[0.670588, 0.235294, 0.0117647],
[0.662745, 0.235294, 0.0117647],
[0.654902, 0.231373, 0.0117647],
[0.65098, 0.227451, 0.0156863],
[0.643137, 0.223529, 0.0156863],
[0.639216, 0.223529, 0.0156863],
[0.631373, 0.219608, 0.0156863],
[0.623529, 0.215686, 0.0156863],
[0.619608, 0.211765, 0.0156863],
[0.611765, 0.211765, 0.0156863],
[0.607843, 0.207843, 0.0156863],
[0.6, 0.203922, 0.0156863],
[0.592157, 0.203922, 0.0156863],
[0.588235, 0.2, 0.0156863],
[0.580392, 0.2, 0.0156863],
[0.576471, 0.196078, 0.0156863],
[0.568627, 0.196078, 0.0156863],
[0.560784, 0.192157, 0.0156863],
[0.556863, 0.192157, 0.0156863],
[0.54902, 0.188235, 0.0196078],
[0.545098, 0.188235, 0.0196078],
[0.537255, 0.184314, 0.0196078],
[0.529412, 0.184314, 0.0196078],
[0.52549, 0.180392, 0.0196078],
[0.517647, 0.180392, 0.0196078],
[0.513725, 0.176471, 0.0196078],
[0.505882, 0.176471, 0.0196078],
[0.501961, 0.176471, 0.0196078],
[0.494118, 0.172549, 0.0196078],
[0.486275, 0.172549, 0.0196078],
[0.482353, 0.168627, 0.0196078],
[0.47451, 0.168627, 0.0196078],
[0.470588, 0.164706, 0.0196078],
[0.462745, 0.164706, 0.0196078],
[0.454902, 0.160784, 0.0196078],
[0.45098, 0.160784, 0.0235294],
[0.443137, 0.156863, 0.0235294],
[0.439216, 0.156863, 0.0235294],
[0.431373, 0.152941, 0.0235294],
[0.423529, 0.152941, 0.0235294],
[0.419608, 0.14902, 0.0235294],
[0.411765, 0.14902, 0.0235294],
[0.407843, 0.145098, 0.0235294],
[0.4, 0.145098, 0.0235294]]

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
