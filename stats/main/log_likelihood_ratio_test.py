# -----------------
# Script for log-likelihood ratio test
# -----------------

# The code and data of this repository are intended to promote transparent and reproducible research
# of the paper "Decoding biological age from face photographs using deep learning"

# All the details about the project can be found at the following webpage:
# aim.hms.harvard.edu/FaceAge

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# AIM 2022

# Import libraries/dependencies
import pickle
from lifelines.statistics import _chisq_test_p_value
from pandas import read_csv

# log-likelihood ratio hypothesis test
def log_likelihood_ratio_test(model_null,model_alt):
    # Compute likelihood ratio test for two competing Cox models.
    ll_null = model_null.log_likelihood_
    ll_alt = model_alt.log_likelihood_
    test_stat = 2 * (ll_alt - ll_null)
    degrees_freedom = model_alt.params_.shape[0] - model_null.params_.shape[0]
    p_value = _chisq_test_p_value(test_stat, degrees_freedom=degrees_freedom)
    return test_stat, p_value, degrees_freedom

# define IO paths
rootpath = './'
inputpath = 'results/'

# baseline model
filename = rootpath + inputpath + 'coxph_model0.sav'
# comparator model
filename = rootpath + inputpath + 'coxph_model1.sav'

# load Cox PH models
with open(filename, 'rb') as pickle_file:
    cph1 = pickle.load(pickle_file)

with open(filename, 'rb') as pickle_file:
    cph0 = pickle.load(pickle_file)

# perform LLR test and print outputs
chi_square, p, df = log_likelihood_ratio_test(cph0, cph1)
print('Log-Likelihood Ratio test: \n')
print('Chi-Square test statistic for %d' % df,
      'additional explanatory variables: %.4f' % chi_square)
print('p-value: %.4f \n' % p)
